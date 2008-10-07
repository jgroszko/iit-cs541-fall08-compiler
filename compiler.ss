#lang scheme

(require mzlib/compat)

(require "helper.ss")
(require "tests-3.1.ss")
(require "tests-3.2.ss")
(require "tests-3.3.ss")
(require "tests-3.4.ss")
(require "tests-3.5.ss")

; --- Boilerplate ---

(define (emit-header)
  (emit ".file \"out.s\"")
  (emit ".text")
  (emit ".p2align 4,,15")
  (emit ".globl scheme_entry")
  (emit ".type scheme_entry, @function")
  (emit "scheme_entry:"))


(define (emit-footer)
  (emit "ret")
  (emit ".size scheme_entry, .-scheme_entry")
  (emit ".ident \"grosjoh1-CS541 Compiler\"")
  (emit ".section .note.GNU-stack,\"\", @progbits"))

; --- Primitives ---
(define-syntax define-primitive
  (syntax-rules ()
    [(_ (prim-name arg* ...) b b* ...)
     (begin
       (putprop 'prim-name '*is-prim* #t)
       (putprop 'prim-name '*arg-count*
		(if (= (length '(arg* ...)) 1)
		    1
		    (- (length '(arg* ...)) 2)))
       (putprop 'prim-name '*emitter*
		(lambda (arg* ...) b b* ...)))]))

(define (primitive? x)
  (and (symbol? x) (getprop x '*is-prim*)))

(define (primitive-emitter x)
  (or (getprop x '*emitter*) (error "primitive-emitter failed.")))

(define (primcall? expr)
  (and (pair? expr) (primitive? (car expr))))

(define (check-primcall-args prim args)
  (if (primitive? prim)
      (if (not (= (getprop prim '*arg-count*) (length args)))
	  (error "check-primcall-args" "argument count does not match" (length args))
	  #t)
      (error "check-primcall-args" "not a primitive" prim)))

(define (emit-primcall expr environment stack-pointer)
  (let ([prim (car expr)] [args (cdr expr)])
    (if (check-primcall-args prim args)
	(if (= (getprop prim '*arg-count*) 1)
	    (apply (primitive-emitter prim) args)
	    (apply (primitive-emitter prim) environment stack-pointer args))
	(error "emit-primcall" "incorrect arguments"))))

(define-primitive ($add1 arg)
  (emit-expr arg)
  (emit "addl $~s, %eax" (immediate-rep 1)))

(define-primitive ($sub1 arg)
  (emit-expr arg)
  (emit "subl $~s, %eax" (immediate-rep 1)))

(define-primitive ($integer->char arg)
  (emit-expr arg)
  (emit "sall $6, %eax")
  (emit "addl $15, %eax"))

(define-primitive ($char->integer arg)
  (emit-expr arg)
  (emit "sarl $6, %eax"))

(define-primitive ($zero? arg)
  (emit-expr arg)
  (emit "cmpl $0, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($null? arg)
  (emit-expr arg)
  (emit "cmpl $47, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($not arg)
  (emit-expr arg)
  (emit "cmpl $31, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($integer? arg)
  (emit-expr arg)
  (emit "andl $3, %eax")
  (emit "cmpl $0, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($boolean? arg)
  (emit-expr arg)
  (emit "andl $127, %eax")
  (emit "cmpl $31, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($+ environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "addl ~s(%esp), %eax" stack-pointer))

(define-primitive ($- environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "neg %eax")
  (emit "addl ~s(%esp), %eax" stack-pointer))

(define-primitive ($* environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "sarl $2, %eax")
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "sarl $2, %eax")
  (emit "imull ~s(%esp)" stack-pointer)
  (emit "sall $2, %eax"))

(define-primitive ($= environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($!= stack-pointer x y)
  (emit-expr x stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setne %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($< stack-pointer x y)
  (emit-expr x stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setg %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($<= stack-pointer x y)
  (emit-expr x stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setge %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($> stack-pointer x y)
  (emit-expr x stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setl %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($>= stack-pointer x y)
  (emit-expr x stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setle %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

; --- Let Expressions ---

(define (variable? x env)
  (not (boolean? (assoc x env))))

(define $let '())
(putprop '$let '*is-let* #t)

(define (let? expr)
  (and (pair? expr) (getprop (car expr) '*is-let*)))

(define (emit-let bindings body env si)
  (let f ((b* bindings) (new-env env) (si si))
    (cond
     ((null? b*) (emit-expr body new-env si))
     (else
      (let ((b (car b*)))
	(emit-expr (cadr b) env si)
	(emit "movl %eax, ~a(%esp)" si)
	(f (cdr b*)
	   (cons (cons (car b) si) new-env)
	   (- si 4)))))))

; --- Immediate Constants ---

(define fixnum-shift 2)

(define character-shift 8)
(define character-tag 15) ; 0x0F

(define boolean-shift 7)
(define boolean-tag 31) ; 0x1F

(define empty-list-tag 47) ; 0x2F

(define (immediate? x)
  (or (integer? x) (char? x) (boolean? x) (null? x)))

(define (immediate-rep x)
  (cond
   ((integer? x) (arithmetic-shift x fixnum-shift))
   ((char? x) (+ (arithmetic-shift (char->integer x) character-shift) character-tag))
   ((boolean? x) (if x 159 31)) ; 0x9F or 0x1F
   ((null? x) empty-list-tag)))

(define (emit-immediate expr)
  (emit "movl $~s, %eax" (immediate-rep expr)))

(define (emit-expr expr [env '()] [stack-pointer -4])
  (cond
   [(immediate? expr) (emit-immediate expr)]
   [(variable? expr env) (emit "movl ~a(%esp), %eax" (cdr (assoc expr env)))]
   [(let? expr) (emit-let (cadr expr) (caddr expr) env stack-pointer)]
   [(primcall? expr) (emit-primcall expr env stack-pointer)]
   [else (error "don't know how to emit that!" expr)]))

; --- Actual Compiler ---

(define (compile-program x)
  (emit-header)
  (emit-expr x)
  (emit-footer))
