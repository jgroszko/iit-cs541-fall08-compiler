#lang scheme

(require mzlib/compat)

(require "helper.ss")
;(require "tests-3.1.ss")
;(require "tests-3.2.ss")
;(require "tests-3.3.ss")
;(require "tests-3.4.ss")
;(require "tests-3.5.ss")
;(require "tests-3.6.ss")
;(require "tests-3.7.ss")
(require "tests-3.8.ss")

; --- Boilerplate ---

(define (emit-header)
  (emit ".file \"out.s\"")
  (emit ".text")
  (emit ".p2align 4,,15")
  (emit ".globl scheme_entry")
  (emit ".type scheme_entry, @function")
  (emit "scheme_entry:")
  ; Set up heap pointer
  (emit "movl 4(%esp), %esi"))

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
		    (- (length '(arg* ...)) 2))
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
	(apply (primitive-emitter prim) environment stack-pointer args)
	(error "emit-primcall" "incorrect arguments"))))

(define-primitive ($add1 environment stack-pointer arg)
  (emit-expr arg environment)
  (emit "addl $~s, %eax" (immediate-rep 1)))

(define-primitive ($sub1 environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "subl $~s, %eax" (immediate-rep 1)))

(define-primitive ($integer->char environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "sall $6, %eax")
  (emit "addl $15, %eax"))

(define-primitive ($char->integer environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "sarl $6, %eax"))

(define-primitive ($zero? environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "cmpl $0, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($null? environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "cmpl $47, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($not environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "cmpl $31, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($integer? environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "andl $3, %eax")
  (emit "cmpl $0, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($boolean? environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "andl $127, %eax")
  (emit "cmpl $31, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($pair? environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "andl $7, %eax")
  (emit "cmpl $1, %eax")
  (emit "movl $0, %eax")
  (emit "sete %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($vector? environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "andl $7, %eax")
  (emit "cmpl $2, %eax")
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

(define-primitive ($!= environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setne %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($< environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setg %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($<= environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setge %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($> environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setl %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

(define-primitive ($>= environment stack-pointer x y)
  (emit-expr x environment stack-pointer)
  (emit "movl %eax, ~s(%esp)" stack-pointer)
  (emit-expr y environment (- stack-pointer 4))
  (emit "cmpl ~s(%esp), %eax" stack-pointer)
  (emit "movl $0, %eax")
  (emit "setle %al")
  (emit "sall $7, %eax")
  (emit "orl $31, %eax"))

; --- Conditional Expressions ---

(define (unique-label)
  (format "label~s" (random 2000)))

(define-primitive ($if environment stack-pointer test consequence alternative)
  (let ((L0 (unique-label)) (L1 (unique-label)))
    (emit-expr test environment stack-pointer)
    (emit "cmpl $~s, %eax" (immediate-rep #f))
    (emit (string-append "je " L0))
    (emit-expr consequence environment stack-pointer)
    (emit (string-append "jmp " L1))
    (emit (string-append L0 ":"))
    (emit-expr alternative environment stack-pointer)
    (emit (string-append L1 ":"))))	  

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
     ((null? b*)   
      (for-each (lambda (body-element)
		  (emit-expr body-element new-env si))
		body))
     (else
      (let ((b (car b*)))
	(emit-expr (cadr b) env si)
	(emit "movl %eax, ~a(%esp)" si)
	(f (cdr b*)
	   (cons (cons (car b) si) new-env)
	   (- si 4)))))))

; --- Pairs ---

(define pair-tag 1) ; 0x1

(define pair-size 8)

(define-primitive ($cons environment stack-pointer first second)
  (emit "/* Save heap spot */")
  (emit "movl %esi, ~a(%esp)" stack-pointer)
  (emit "addl $8, %esi")

  (emit "/* Call first */")
  (emit-expr first environment (- stack-pointer 4))
  (emit "/* Save first to heap */")
  (emit "movl ~a(%esp), %ebx" stack-pointer)
  (emit "movl %eax, 0(%ebx)")

  (emit "/* Call second */")
  (emit-expr second environment (- stack-pointer 4))
  (emit "/* Save second to heap */")
  (emit "movl ~a(%esp), %ebx" stack-pointer)
  (emit "movl %eax, 4(%ebx)")

  (emit "/* Create pointer to pair */")
  (emit "movl ~a(%esp), %eax" stack-pointer)
  (emit "orl $~s, %eax" pair-tag))

(define-primitive ($car environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "movl -1(%eax), %eax"))

(define-primitive ($cdr environment stack-pointer arg)
  (emit-expr arg environment stack-pointer)
  (emit "movl 3(%eax), %eax"))

; --- Vectors ---

(define vector-tag 2) ; 0x2

(define-primitive ($make-vector environment stack-pointer size)
  (emit "/* Vector Size */")
  (emit-expr size environment stack-pointer)

  (emit "/* Save size to heap */")
  (emit "movl %eax, 0(%esi)")

  (emit "/* Pad the vector's size */")
  (emit "addl $11, %eax")
  (emit "andl $-8, %eax")

  (emit "/* Save heap spot */")
  (emit "movl %esi, ~a(%esp)" stack-pointer)

  (emit "/* Increment heap pointer */")
  (emit "sarl $~s, %eax" fixnum-shift) ; Convert back to an actual number
  (emit "imull $4, %eax") ; Word size 4
  (emit "addl %eax, %esi")

  (emit "/* Create pointer to pair */")
  (emit "movl ~a(%esp), %eax" stack-pointer)
  (emit "orl $~s, %eax" vector-tag))

(define-primitive ($vector-length environment stack-pointer vector)
  (emit "/* vector-length */")
  (emit-expr vector environment stack-pointer)
  (emit "/* subtract tag */")
  (emit "subl $2, %eax") ; Subtract tag
  (emit "movl (%eax), %eax"))

(define-primitive ($vector-set! environment stack-pointer vector index expr)
  (emit "/* set-vector! */")
  (emit-expr vector environment stack-pointer)
  (emit "/* subtract tag */")
  (emit "subl $2, %eax") ; Subtract tag
  (emit "movl %eax, ~a(%esp)" stack-pointer) ; Save base pointer
  (emit-expr index environment (- stack-pointer 4))
  (emit "sarl $~s, %eax" fixnum-shift)
  (emit "addl $1, %eax")
  (emit "imull $4, %eax")
  (emit "addl ~a(%esp), %eax" stack-pointer)
  (emit "movl %eax, ~a(%esp)" stack-pointer) ; Save destination pointer
  (emit-expr expr environment (- stack-pointer 4))
  (emit "movl ~a(%esp), %ebx" stack-pointer)
  (emit "movl %eax, (%ebx)"))
  

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
  (emit "/* emit: ~s stack: ~s environment: ~s */" expr stack-pointer env)
  (cond
   [(immediate? expr) (emit-immediate expr)]
   [(variable? expr env) (emit "movl ~a(%esp), %eax" (cdr (assoc expr env)))]
   [(let? expr) (emit-let (cadr expr) (cddr expr) env stack-pointer)]
   [(primcall? expr) (emit-primcall expr env stack-pointer)]
   [else (error "don't know how to emit that!" expr)]))

; --- Actual Compiler ---

(define (compile-program x)
  (emit-header)
  (emit-expr x)
  (emit-footer))
