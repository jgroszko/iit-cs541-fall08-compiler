#lang scheme

(require "helper.ss")

(add-tests-with-string-output "procedure calls"
			      [($labels ((foo ($code () 6)))
					($labelcall foo ())) => "6"]
			      [($labels ((foo ($code (x) x)))
					($labelcall foo (#t))) => "#t"]
			      [($labels ((foo ($code (x y) y)))
					($labelcall foo (#t #f))) => "#f"]
			      [($labels ((foo ($code (x y z) z)))
					($labelcall foo (1 2 3))) => "3"]
			      [($labels ((foo ($code (x) ($add1 x))))
					($labelcall foo (5))) => "6"]
			      [($labels ((foo ($code (x y) ($>= x y))))
					($labelcall foo (4 5))) => "#f"]
			      [($labels ((foo ($code (x y z) ($+ x ($+ y z)))))
					($labelcall foo (1 2 3))) => "6"]
			      [($labels ((foo ($code (x y) ($+ x y)))
					 (bar ($code (x y) ($- x y))))
					($labelcall bar (($labelcall foo (1 2)) 3))) => "0"]
)