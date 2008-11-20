#lang scheme

(require "helper.ss")

(add-tests-with-string-output "procedure calls"
			      [($labels ((six ($code () 6)))
					($labelcall six ())) => "6"]
			      [($labels ((six ($code (x) x)))
					($labelcall six (#t))) => "#t"]
			      [($labels ((six ($code (x y) y)))
					($labelcall six (#t #f))) => "#f"]
			      [($labels ((six ($code (x y z) z)))
					($labelcall six (1 2 3))) => "3"]

)