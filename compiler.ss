#lang scheme

(define (compile-program x)
  (define (emit-header out)
    ; Boilerplate header stuff
    (emit ".file \"out.s\"" out)
    (emit ".text" out)
    (emit ".p2align 4,,15" out)
    (emit ".globl scheme_entry" out)
    (emit ".type scheme_entry, @function" out)
    (emit "scheme_entry:" out))

  (define (emit-footer out)
    ; Boilerplate footer stuff
    (emit ".size scheme_entry, .-scheme_entry" out)
    (emit ".ident \"grosjoh1-CS541 Compiler\"" out)
    (emit ".section .note.GNU-stack,\"\", @progbits" out))

  (define (emit str out)
    (display (string-append str "\n") out))
  
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

  (call-with-output-file "out.s"
    #:exists 'truncate
    (lambda (out)
      (emit-header out)

      (emit (format "movl $~a, %eax" (immediate-rep x)) out)
      (emit "ret" out)

      (emit-footer out))))