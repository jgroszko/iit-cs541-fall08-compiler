#lang scheme

(require "helper.ss")

(add-tests-with-string-output "immediate constants"
			      [() => "()"]
			      [#\A => "A"]
			      [#t => "1"])