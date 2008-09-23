#lang scheme

(require "helper.ss")
(require "tests-3.1.ss")
(require "tests-3.2.ss")

(define (emit-header)
  ; Boilerplate header stuff
  (emit ".file \"out.s\"")
  (emit ".text")
  (emit ".p2align 4,,15")
  (emit ".globl scheme_entry")
  (emit ".type scheme_entry, @function")
  (emit "scheme_entry:"))


(define (emit-footer)
  ; Boilerplate footer stuff
  (emit ".size scheme_entry, .-scheme_entry")
  (emit ".ident \"grosjoh1-CS541 Compiler\"")
  (emit ".section .note.GNU-stack,\"\", @progbits"))

(define (compile-program x)
  
  ; Constants
  (define fixnum-shift 2)

  (define character-shift 8)
  (define character-tag 15) ; 0x0F

  (define boolean-shift 7)
  (define boolean-tag 31) ; 0x1F

  (define empty-list-tag 47) ; 0x2F


  (define (immediate-rep x)
    (cond
     ((integer? x) (arithmetic-shift x fixnum-shift))
     ((char? x) (+ (arithmetic-shift (char->integer x) character-shift) character-tag))
     ((boolean? x) (if x 159 31)) ; 0x9F or 0x1F
     ((null? x) empty-list-tag)))

  (emit-header)

  (emit (format "movl $~a, %eax" (immediate-rep x)))
  (emit "ret")
  
  (emit-footer))