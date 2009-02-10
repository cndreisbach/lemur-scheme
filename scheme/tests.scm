(print "Scheme tests")

(asserteq "not #t should be #f" (not #t) #f)
(asserteq "not #f should be #t" (not #f) #t)

(assert "boolean? should work"
  (and
    (boolean? #t)
    (boolean? #f)
    (not (boolean? 1))
    (not (boolean? "a"))
    (not (boolean? ()))
  ))

(assert "number? should work"
  (and
    (number? 1)
    (number? (/ 16 3))
    (number? 3.14)
    (not (number? #t))
    (not (number? "a"))
    (not (number? ()))
  ))
    
(assert "symbol? should work"
  (and 
    (symbol? (quote hello))
    (not (symbol? #f))
    (not (symbol? 7))
    (not (symbol? "string"))
  ))

(assert "string? should work"
  (and
    (string? "string")
    (not (string? (quote hello)))
    (not (string? 1))
    (not (string? #t))
  ))

(assert "procedure? should work"
  (and
    (procedure? (lambda () 1))
    (procedure? +)
    (procedure? assert)
    (not (procedure? #t))
    (not (procedure? "lambda"))
    (not (procedure? (quote /)))
  ))