#lang scheme

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

(define (compile-program x)
  (call-with-output-file "out.s"
    #:exists 'truncate
    (lambda (out)
      (emit-header out)

      (emit (format "movl $~a, %eax" x) out)
      (emit "ret" out)

      (emit-footer out))))