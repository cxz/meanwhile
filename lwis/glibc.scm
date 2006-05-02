

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


(define strdup
  (lambda (expr)
    (lwis-call "strdup" `(,expr))))


;; todo include target-based extension


;; The end.
