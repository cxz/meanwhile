

(define free
  (lambda (expr)
    (lwis-call "free" `(,expr))))


(define strlen
  (lambda (expr)
    (lwis-call "strlen" `(,expr))))


(define malloc
  (lambda (expr)
    (lwis-call "malloc" `(,expr))))


(define strcpy
  (lambda (expr_to expr_from)
    (lwis-call "strcpy" `(,expr_to ,expr_from))))


;; expression that will result in a duplicate allocation of a string
;; expression. note that this evaluates expr twice, once to get the
;; length, and again to copy from it
(define strdup
  (lambda (expr)
    (strcpy (malloc (lwis+ (strlen expr) (lwis-literal 1))) expr)))


;; todo include target-based extension


;; The end.
