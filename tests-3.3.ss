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

(add-tests-with-string-output "sub1"
			      [($sub1 0)  => "-1"]                    
			      [($sub1 1)  => "0"]                    
			      [($sub1 -100) => "-101"]                   
			      [($sub1 1000)  => "999"]                    
			      [($sub1 536870910) => "536870909"]
			      [($sub1 -536870911) => "-536870912"]
			      [($sub1 ($sub1 0)) => "-2"]
			      [($sub1 ($sub1 ($sub1 ($sub1 ($sub1 ($sub1 12)))))) => "6"]
			      )

(add-tests-with-string-output "integer->char"
			      [($integer->char 65) => "#\\A"]
			      [($integer->char 90) => "#\\Z"]
			      [($integer->char 97) => "#\\a"]
			      [($integer->char 122) => "#\\z"]
			      [($integer->char 48) => "#\\0"]
			      [($integer->char 57) => "#\\9"]			      
			      )

(add-tests-with-string-output "char->integer"
			      [($char->integer #\A) => "65"]
			      [($char->integer #\Z) => "90"]
			      [($char->integer #\a) => "97"]
			      [($char->integer #\z) => "122"]
			      [($char->integer #\0) => "48"]
			      [($char->integer #\9) => "57"]			      
			      )

(add-tests-with-string-output "zero?"
			      [($zero? 0) => "#t"]
			      [($zero? 1) => "#f"]
			      [($zero? #\A) => "#f"])

(add-tests-with-string-output "null?"
;			      [($null? ()) => "#t"]
;			      [($null? 1) => "#f"]
;			      [($null? #\A) => "#f"]
)

(add-tests-with-string-output "not"
			      [($not #t) => "#f"]
			      [($not #f) => "#t"]
			      [($not ()) => "#f"]
			      [($not 1) => "#f"]
			      [($not #\A) => "#f"])

(add-tests-with-string-output "integer?"
			      [($integer? #t) => "#f"]
			      [($integer? #f) => "#f"]
			      [($integer? ()) => "#f"]
			      [($integer? 1) => "#t"]
			      [($integer? 10) => "#t"]
			      [($integer? #\A) => "#f"])

(add-tests-with-string-output "boolean?"
			      [($boolean? #t) => "#t"]
			      [($boolean? #f) => "#t"]
			      [($boolean? ()) => "#f"]
			      [($boolean? 1) => "#f"]
			      [($boolean? 10) => "#f"]
			      [($boolean? #\A) => "#f"])
			      
