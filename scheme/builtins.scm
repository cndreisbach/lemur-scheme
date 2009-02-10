(define (car x) (! x car))
(define (cdr y) (! y cdr))
(define (not x) (eq? x #f))

(define (boolean? x) (or (eq? x #t) (eq? x #f)))
(define (number? x) (! x is_a? (ruby Numeric)))
(define (symbol? x) (and (not (boolean? x)) (! x is_a? (ruby Symbol))))
(define (string? x) (! x is_a? (ruby String)))
(define (procedure? x) (! x respond_to? "call"))

(define (quit) (! (ruby Kernel) exit))

(define (reportmsg msg) (print msg))
(define (reporterr msg) (print (+ "ERROR: " msg)))
(define (assert msg b) (if (not b) (reporterr msg) (reportmsg "PASS")))
(define (asserteq msg a b) (assert msg (eq? a b)))

(defmacro let1 (lambda (binding body) (list (list (quote lambda) (list (car binding)) body) (car (cdr binding)))))
