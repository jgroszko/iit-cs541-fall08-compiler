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

)