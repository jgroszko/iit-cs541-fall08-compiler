#lang scheme

(require "helper.ss")

(add-tests-with-string-output "add1"
			      [($add1 0)  => "1"]                    
			      [($add1 1)  => "2"]                    
			      [($add1 -100) => "-99"]                   
			      [($add1 1000)  => "1001"]                    
			      [($add1 536870910) => "536870911"]
			      [($add1 -536870912) => "-536870911"]
			      [($add1 ($add1 0)) => "2"]
			      [($add1 ($add1 ($add1 ($add1 ($add1 ($add1 12)))))) => "18"]
			      )
