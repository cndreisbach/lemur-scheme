(define car (lambda (x) (! x car)))
(define cdr (lambda (y) (! y cdr)))
(define quit (lambda () (! (ruby Kernel) exit)))
(define not (lambda (x) (if (eq? x #f) #t #f)))

(defmacro let1 (lambda (binding body) (list (list (quote lambda) (list (car binding)) body) (car (cdr binding)))))
(defmacro or (lambda (x y) (list (quote let1) (list (quote result) x) (list (quote if) (quote result) (quote result) y))))
(defmacro and (lambda (x y) (if (eval x) y #f)))

(define reportmsg (lambda (msg) (print msg)))
(define reporterr (lambda (msg) (print (+ "ERROR: " msg))))
(define assert (lambda (msg b) (if (not b) (reporterr msg) (reportmsg "PASS"))))
(define asserteq (lambda (msg a b) (assert msg (eq? a b))))
