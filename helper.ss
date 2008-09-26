#lang scheme

(require scheme/system)

; Compiling Helpers

(define compile-func
  (make-parameter
   '()
   (lambda (p)
     (unless (procedure? p)
	     (error 'compile-funt "not a procedure ~s" p))
     p)))

(define compile-port
  (make-parameter
   (current-output-port)
   (lambda (p)
     (unless (output-port? p)
	     (error 'compile-port "not an output port ~s" p))
     p)))

(provide emit)

(define (emit . args)
  (apply fprintf (compile-port) args)
  (newline (compile-port)))

; Building stuff

(define (run-compile expr)
  (let ([p (open-output-file "stst.s" #:exists 'replace)])
    (parameterize ([compile-port p])
		  ((compile-func) expr)
		  (close-output-port p))))

(define (build)
  (unless (system "gcc -g -gstabs -o stst driver.c stst.s")
	  (error 'make "could not build target")))

(define (execute)
  (unless (system "./stst > stst.out")
	  (error 'make "produced program exited abnormally")))

(define (build-program expr)
  (run-compile expr)
  (build))

(define (get-string)
  (call-with-input-file "stst.out"
    (lambda (in)
      (read-line in))))

; Testing

(provide test-with-string-output)

(define (test-with-string-output test-id expr expected-output)
  (run-compile expr)
  (build)
  (execute)
  (unless (string=? expected-output (get-string))
	  (error 'test "output mismatch for test ~s, expected ~s, got ~s"
		 test-id expected-output (get-string))))

(provide all-tests)
(provide add-tests-with-string-output)

(define all-tests '())

(define (cons-all-tests new-test)
  (set! all-tests
	(cons
	 new-test
	 all-tests)))

(define-syntax add-tests-with-string-output
  (syntax-rules (=>)
    [(_ test-name [expr => output-string] ...)
     (cons-all-tests
      '(test-name [expr output-string] ...))]))

(define (test-one test-id test)
  (let ([expr (car test)]
	[out (car (cdr test))])
    (printf "test ~s:~s ..." test-id expr)
    (test-with-string-output test-id expr out)
    (printf " ok\n")))

(provide test-all)

(define (test-all compile-program)
  (parameterize ([compile-func compile-program])
		(let f ([i 0] [ls all-tests])
		  (if (null? ls)
		      (printf "Passed all ~s tests\n" i)
		      (let ([x (car ls)]
			    [ls (cdr ls)])
			(let ([test-name (car x)]
			      [tests (cdr x)])
			  (printf "Performing test ~s\n" test-name)
			  (let g ([i i]
				  [tests tests])
			    (if (null? tests)
				(f i ls)
				((test-one test-name (car tests))
				 (g (add1 i) (cdr tests)))))))))))

	      

