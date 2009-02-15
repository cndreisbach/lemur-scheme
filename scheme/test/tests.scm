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
  
(assert "pair? should work" 
  (and
    (pair? (cons 1 2))
    (pair? (cons 1 (cons 2 ())))
    (not (pair? (quote a)))
    (not (pair? ()))
  ))

(asserteq "if should be able to have two clauses and result in then" 1 (if (eq? 1 1) 1 2))
(asserteq "if should be able to have two clauses and result in else" 2 (if (eq? 1 2) 1 2))
(asserteq "if should be able to have only one clause and result in then" 1 (if (eq? 1 1) 1))
(asserteq "if should be able to have only one clause and result in false" #f (if (eq? 1 2) 1))

(asserteq "cond should work" 2
  (cond (#f 1)
        (#t 2)
        (#f (reporterr "cond is evaling expressions it shouldn't"))
    ))

(asserteq "else should work" 2
  (cond (#f 1)
        (else 2)
    ))

(assert "quasiquote and unquote should work"
  (begin
    (define x 23)
    (eq? (quote (+ (* 2 23) 1)) (quasiquote (+ (* 2 (unquote x)) 1)))
  ))
