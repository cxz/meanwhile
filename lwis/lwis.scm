#!/usr/bin/guile \
--debug -e lwis-main -s
!#


;; because getopt-long sucks
(load "lwis-getopt.scm")


;; required lwis library
(load "lib.scm")


;; app globals
(define defns (make-hash-table 8))
(define search '())
(define target "")
(define output "")


(define lwis-cli-help!
  (lambda () #f))


(define lwis-cli-version!
  (lambda () #f))

  
;; main entry point for the LWIS application. command-line parameters
;; define the library wrapper definition to be used, the target
;; language, the output filename, and a search path for LWIS modules,
;; as well as some run-time variables
(define lwis-main
  (lambda (cmdline)
    
    (let* ((sopts "hvI:D:t:o:")
	   (lopts `(,"help" ,"version" ,"search=" ,"define="
		    ,"target=" ,"output="))
	   (gotopts (getopt (cdr cmdline) sopts lopts))
	   (ol (car gotopts))
	   (al (cdr gotopts)))
      
      ;; handle the various options in the order they were specified
      (for-each 
       (lambda (kv)
	 (let ((k (car kv)) (v (cdr kv)))
	   (cond
	    ((or (equal? "--help" k)
		 (equal? "-h" k))
	     (lwis-cli-help!))

	    ((or (equal? "--version" k)
		 (equal? "-v" k))
	     (lwis-cli-version!))

	    ((or (equal? "--search" k)
		 (equal? "-I" k))
	     (set! search (cons v search)))

	    ((or (equal? "--define" k)
		 (equal? "-D" k))
	     (let* ((i (string-index v #\=))
		    (dk (if i (substring v 0 i) v))
		    (dv (if i (substring v (+ i 1)) "")))
	       (hash-set! defns dk dv)))

	    ((or (equal? "--target" k)
		 (equal? "-t" k))
	     (set! target v))

	    ((or (equal? "--output" k)
		 (equal? "-o" k))
	     (set! output v))
	    )))
       ol)
      
      ;; ensure a target
      (cond
       ((equal? "" target)
	(display "please specify a target")
	(newline)
	(exit 1))
       (else
	(hash-set! defns "TARGET" target)
	(load (format #f "~a.scm" target))))

      ;; todo
      ;; load each *.$target.scm file in the search path
      
      ;; load the first argument as the module definition. the module
      ;; definition should call lwis-produce after setting itself up
      (cond
       ((or (null? al)
	    (not (null? (cdr al))))
	(display "please specify a single module definition")
	(newline)
	(lwis-cli-help!))
       (else
	(display "loading module definition... ")
	(load (car al))))
      
      (display "done.")
      (newline)
      )))



(define lwis-get-defn
  (lambda (key)
    (hash-ref defns key)))



;; this makes it so (@ DEF_NAME) works without needing a quote
(defmacro @ (key)
  `(lwis-get-defn ,(format #f "~a" key)))



(define lwis-load
  (lambda (filename)
    ;; todo find filename in search path and load it
    #f))



(define lwis-produce
  (lambda (module)

    ;; ensure there's an output, make one up if there isn't.
    (if (equal? "" output)
	(set! output (format #f "wrap_~a.c" (module 'get-name))))

    ;; ensure there's a target-produce function
    (if (not (defined? 'target-produce))
	(error "no target-produce function defined."))

    ;; open the output file, use target-produce to generate an
    ;; expression, then create a lambda as an output function for that
    ;; expression and evaluate it.
    (let* ((outfd (if (equal? "-" output)
		      #f (open output (logior O_RDWR O_CREAT))))
	   (outfn (if outfd
		      (lambda (s) (display s outfd))
		      (lambda (s) (display s)))))
      
      ((target-produce module) outfn)
      (if outfd (close outfd)))))



;; The end.
