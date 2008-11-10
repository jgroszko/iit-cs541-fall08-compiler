#lang scheme

(require "helper.ss")

(add-tests-with-string-output "make-vector"
			      [($make-vector 1) => "#(0)"]
			      [($make-vector 2) => "#(0 . 0)"]
			      [($make-vector 3) => "#(0 . 0 . 0)"]
			      [($let ((v ($make-vector 2)))
				     ($vector-set! v 0 #t)
				     ($vector-set! v 1 #f)
				     v) => "#(#t . #f)"]
			      [($let ((v ($make-vector 4)))
				     ($vector-set! v 0 1)
				     ($vector-set! v 1 2)
				     ($vector-set! v 2 3)
				     ($vector-set! v 3 4)
				     v) => "#(1 . 2 . 3 . 4)"]
			      [($vector? ($make-vector 0)) => "#t"]
			      [($vector-length ($make-vector 12)) => "12"]
			      [($vector? ($cons 1 2)) => "#f"]
			      [($vector? 1287) => "#f"]
			      [($vector? ()) => "#f"]
			      [($vector? #t) => "#f"]
			      [($vector? #f) => "#f"]
			      [($pair? ($make-vector 12)) => "#f"]
			      [($null? ($make-vector 12)) => "#f"]
			      [($boolean? ($make-vector 12)) => "#f"]
			      [($make-vector 0) => "#()"]
			      [($let ([v ($make-vector 2)])
				 ($vector-set! v 0 #t)
				 ($vector-set! v 1 #f)
				 v) => "#(#t . #f)"]
			      [($let ([v0 ($make-vector 2)])
				 ($let ([v1 ($make-vector 2)])
				   ($vector-set! v0 0 100)
				   ($vector-set! v0 1 200)
				   ($vector-set! v1 0 300)
				   ($vector-set! v1 1 400)
				   ($cons v0 v1))) => "(#(100 . 200) . #(300 . 400))"]
			      [($let ([v0 ($make-vector 3)])
				 ($let ([v1 ($make-vector 3)])
				   ($vector-set! v0 0 100)
				   ($vector-set! v0 1 200)
				   ($vector-set! v0 2 150)
				   ($vector-set! v1 0 300)
				   ($vector-set! v1 1 400)
				   ($vector-set! v1 2 350)
				   ($cons v0 v1))) => "(#(100 . 200 . 150) . #(300 . 400 . 350))"]
			      [($let ([n 2])
				 ($let ([v0 ($make-vector n)])
				   ($let ([v1 ($make-vector n)])
				     ($vector-set! v0 0 100)
				     ($vector-set! v0 1 200)
				     ($vector-set! v1 0 300)
				     ($vector-set! v1 1 400)
				     ($cons v0 v1)))) => "(#(100 . 200) . #(300 . 400))"]
			      [($let ([n 3])
				 ($let ([v0 ($make-vector n)])
				   ($let ([v1 ($make-vector ($vector-length v0))])
				     ($vector-set! v0 ($- ($vector-length v0) 3) 100)
				     ($vector-set! v0 ($- ($vector-length v1) 2) 200)
				     ($vector-set! v0 ($- ($vector-length v0) 1) 150)
				     ($vector-set! v1 ($- ($vector-length v1) 3) 300)
				     ($vector-set! v1 ($- ($vector-length v0) 2) 400)
				     ($vector-set! v1 ($- ($vector-length v1) 1) 350)
				     ($cons v0 v1)))) => "(#(100 . 200 . 150) . #(300 . 400 . 350))"]
			      [($let ([n 1])
				 ($vector-set! ($make-vector n) ($sub1 n) ($* n n))
				 n) => "1"]
			      )