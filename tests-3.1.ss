#lang scheme

(require "helper.ss")

(add-tests-with-string-output "fixnums"
			      [0 => "0"]
			      [-1 => "-1"]
			      [10 => "10"])