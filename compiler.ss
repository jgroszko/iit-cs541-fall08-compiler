#lang scheme

(define (emit str out)
  (display (string-append str "\n") out))

(define (compile-program x)
  (call-with-output-file "out.s"
    #:exists 'truncate
    (lambda (out)
      (emit (format "mov1 $~a, %eax" x) out)
      (emit "ret" out))))