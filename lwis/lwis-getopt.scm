;; Problem: long_getopts doesn't allow multiple instances of the same option.
;; Solution: write something that looks vaguely like gnu getopt
;;
;; author: siege@preoccupied.net
;; date: 2006-05-01



(define getopt_shortspec
  (lambda (str)
    (let next ((sl (string->list str)))
      (cond
       ((null? sl) '())
       ((or (null? (cdr sl))
	    (not (equal? #\: (cadr sl))))
	(cons `(,(string (car sl)) . ,#f)
	      (next (cdr sl))))
       (else
	(cons `(,(string (car sl)) . ,#t)
	      (next (cddr sl))))))))



(define _aslongspec
  (lambda (str)
    (let ((i (string-rindex str #\=)))
      (if i
	  `(,(substring str 0 i) . ,#t)
	  `(,str . ,#f)))))



(define getopt_longspec
  (lambda (strl)
    (cond
     ((null? strl) '())
     (else
      (cons (_aslongspec (car strl))
	    (getopt_longspec (cdr strl)))))))



(define isopt?
  (lambda (str)
    (let* ((sl (string->list str))
	   (sn (length sl)))
      (or
       (and (eq? sn 2)
	    (eq? (car sl) #\-))

       (and (>= sn 3)
	    (eq? (car sl) #\-)
	    (eq? (cadr sl) #\-))))))



(define asopt
  (lambda (str)
    (let* ((sl (string->list str))
	   (sn (length sl)))
      
      (cond
       ((and (eq? sn 2)
	     (eq? (car sl) #\-))
	(list->string (cdr sl)))

       ((and (>= sn 3)
	     (eq? (car sl) #\-)
	     (eq? (cadr sl) #\-))
	(list->string (cddr sl)))

       (else str)))))



(define getopt_spec&co
  (lambda (args spec col)
    (cond
     ((null? args) (col '() '()))
     ((isopt? (car args))
      (let* ((opt (assoc (asopt (car args)) spec)))
	(cond
	 
	 ((not opt)
	  ;; no such option
	  (error "unknown option" (car args)))
	 
	 ((not (cdr opt))
	  ;; option doesn't take a param
	  (getopt_spec&co
	   (cdr args) spec
	   (lambda (o a) (col (cons `(,(car args) . ,#t) o) a)))
	  )
	 
	 (else
	  ;; option takes a param
	  (if (null? (cdr args))
	      (error "missing argument to option" (car args))
	      (getopt_spec&co
	       (cddr args) spec
	       (lambda (o a) (col (cons `(,(car args) . ,(cadr args)) o) a))))
	  ))))
     
     (else
      ;; a trailing arg
      (getopt_spec&co
       (cdr args) spec
       (lambda (o a) (col o (cons (car args) a))))
      ))))



(define getopt_spec
  (lambda (args spec)
    (getopt_spec&co args spec (lambda (o a) `(,o . ,a)))))



;; calls col with a pair of lists. The first list is a list of string
;; . val pairs indicating options and values, the second list is a
;; list of non-option arguments. See getopt
(define getopt&co
  (lambda (args opts longopts col)
    (getopt_spec&co
     args
     (append (getopt_shortspec opts) (getopt_longspec longopts))
     col)))



;; results in a pair of lists. The first list is a list of string
;; . val pairs indicating options and values, the second list is a
;; list of non-option arguments
;;
;; args is a list of arguments to parse
;; opts is a string indicating short arguments
;; longopts is a list of long argument names
;;
;; example  (getopt (cdr (command-line))
;;                  "hvVo:c:"
;;                  `(,"help" ,"version" ,"verbose" ,"output=" ,"config="))
;;
(define getopt
  (lambda (args opts longopts)
    (getopt&co args opts longopts (lambda (o a) `(,o . ,a)))))


;; The end.
