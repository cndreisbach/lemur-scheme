(define (car x) (! x car))
(define (cdr y) (! y cdr))
(define (quit) (! (ruby Kernel) exit))
(define (not x) (if (eq? x #f) #t #f))

(define (reportmsg msg) (print msg))
(define (reporterr msg) (print (+ "ERROR: " msg)))
(define (assert msg b) (if (not b) (reporterr msg) (reportmsg "PASS")))
(define (asserteq msg a b) (assert msg (eq? a b)))

(defmacro let1 (lambda (binding body) (list (list (quote lambda) (list (car binding)) body) (car (cdr binding)))))
(defmacro or (lambda (x y) (list (quote let1) (list (quote result) x) (list (quote if) (quote result) (quote result) y))))
(defmacro and (lambda (x y) (if (eval x) y #f)))