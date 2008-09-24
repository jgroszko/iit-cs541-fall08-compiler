#lang scheme

(require mzlib/compat)

(require "helper.ss")
(require "tests-3.1.ss")
;(require "tests-3.2.ss")
(require "tests-3.3.ss")

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
		(length '(arg* ...)))
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

(define (emit-primcall expr)
  (let ([prim (car expr)] [args (cdr expr)])
    (if (check-primcall-args prim args)
	(apply (primitive-emitter prim) args)
	(error "emit-primcall" "incorrect arguments"))))

(define-primitive ($add1 arg)
  (emit-expr arg)
  (emit "addl $~s, %eax" (immediate-rep 1)))

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

(define (emit-expr expr)
  (cond
   [(immediate? expr) (emit-immediate expr)]
   [(primcall? expr) (emit-primcall expr)]
   [else (error "don't know how to emit that!" expr)]))

; --- Actual Compiler ---

(define (compile-program x)
  (emit-header)
  (emit-expr x)
  (emit-footer))
