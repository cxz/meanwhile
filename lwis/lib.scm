;; common LWIS utilities for defining types and generating expressions


;; this part sucks, because it requires Guile, but we "need" srfi-1
;; todo: just implement our own version of find
;(use-modules (srfi srfi-1))


;; load once
;(define require
;  (let ((loaded '()))
;    (lambda (s)
;      (display "require ")
;      (display s)
;      (newline)
;
;      (cond
;       ((not (find (lambda (a) (string=? a s)) loaded))
;	(load s)
;	(set! loaded (cons s loaded))
;	(display "loaded ")
;	(display loaded)
;	(newline)
;	#t)
;       (else #f)))))


(define require load)



;;  type that doesn't get wrapped or unwrapped
(define lwis-target-type-new
  (lambda (name)
    (lwis-type-new name #f lwis-noop lwis-noop)))



;; type definition
;; methods:
;;   get-name       str, c name for this type
;;   get-target     type, that we wrap to, unwrap from
;;   wrap var       expr, that wraps a variable
;;   unwrap var     expr, that unwraps a variable
;;   dup var        expr, that duplicates a variable (new copy or reference)
;;   dupw var       expr, that duplicates a variable (new copy or reference)
;;   del var        expr, that deletes a variable copy or reference
;;   delw var       expr, that deletes a variable copy or reference
;;   get var        expr, that evaluates to the variable
;;   getw var       expr, that evaluates to the variable
;;   set var ex     expr, that sets the variable to an expression
;;   setw var ex    expr, that sets the variable to an expression
;;   declare var    expr, that declares the variable
;;   declarew var   expr, that declares the variable
;;   set-dup f      nil, sets the type's dup function
;;   set-del f      nil, sets the type's del function
;;   set-getter f   nil, sets the type's get function
;;   set-setter f   nil, sets the type's set function
;;   set-declare f  nil, sets the type's declare function
(define lwis-type-new
  (lambda (name target-type wrap unwrap)

    (define _setter
      (lambda (var expr)
	(lwis= (lwis-literal (var 'get-name)) expr)))

    (define _getter
      (lambda (var)
	(lwis-literal (var 'get-name))))

    (define _declare
      (lambda (var)
	(lambda (output)
	  (output (lwis-printf
		   (if (string=? "" (var 'get-flags)) "~a~a ~a" "~a ~a ~a")
		   (var 'get-flags) name (var 'get-name))))))

    (let ((dup lwis-noop)
	  (del lwis-noop)
	  (setter _setter)
	  (getter _getter)
	  (declare _declare))
      
      (define self
	(lambda args
	  (apply
	   (case (car args)
	     ((get-name) get-name)
	     ((get-target) get-target)
	     ((wrap) wrap)
	     ((unwrap) unwrap)
	     ((dup) dup)
	     ((del) del)
	     ((get) getter)
	     ((set) setter)
	     ((declare) declare)
	     ((set-dup) set-dup)
	     ((set-del) set-del)
	     ((set-getter) set-getter)
	     ((set-setter) set-setter)
	     ((set-declare) set-declare)
	     (else (error "No such method ~s in lwis-type" (car args))))
	   (cdr args))))
      
      (define get-name
	(lambda () name))
      
      (define get-target
	(lambda () target-type))
      
      (define set-dup
	(lambda (dupfunc) (set! dup dupfunc)))
      
      (define set-del
	(lambda (delfunc) (set! del delfunc)))
      
      (define set-getter
	(lambda (getterfunc) (set! getter getterfunc)))
      
      (define set-setter
	(lambda (setterfunc) (set! setter setterfunc)))

      (define set-declare
	(lambda (declarefunc) (set! declare declarefunc)))
      
      self)))



(define lwis-var-new
  (lambda (type name)
    
    (let ((flags "")
	  (wrapped #f))
      
      (define self
	(lambda args
	  (apply
	   (case (car args)
	     ((get-type) get-type)
	     ((get-wrapped-type) get-wrapped-type)
	     ((get-name) get-name)
	     ((get-wrapped-name) get-wrapped-name)
	     ((declare) declare)
	     ((declare-wrapped) declare-wrapped)
	     ((get-flags) get-flags)
	     ((set-flags) set-flags)
	     ((get) get)
	     ((get-wrapped) get-wrapped)
	     ((set) set)
	     ((set-wrapped) set-wrapped)
	     ((dup) dup)
	     ((dup-wrapped) dup-wrapped)
	     ((del) del)
	     ((del-wrapped) del-wrapped)
	     ((wrap) wrap)
	     ((unwrap) unwrap)
	     (else (error "No such method ~a" (car args))))
	   (cdr args))))
    
      
      (define get-type
	(lambda () type))
      
      (define get-wrapped-type
	(lambda () (type 'get-target-type)))
      
      (define get-name
	(lambda () name))

      (define get-wrapped-name
	(lambda ()
	  (if wrapped  (wrapped 'get-name))))

      (define declare
	(lambda ()
	  (type 'declare self)))
      
      (define declare-wrapped
	(lambda ()
	  (if wrapped (wrapped 'declare) (lwis-noop))))

      (define get-flags
	(lambda () flags))

      (define set-flags
	(lambda (new-flags)
	  (set! flags new-flags)
	  flags))
      
      (define get
	(lambda ()
	  (type 'get self)))
      
      (define get-wrapped
	(lambda ()
	  (if wrapped (wrapped 'get) (lwis-noop))))
      
      (define set
	(lambda (expr)
	  (type 'set self expr)))
      
      (define set-wrapped
	(lambda (expr)
	  (if wrapped (wrapped 'set expr) expr)))
      
      (define dup
	(lambda ()
	  (type 'dup (get))))
      
      (define dup-wrapped
	(lambda ()
	  (if wrapped (wrapped 'dup))))
      
      (define del
	(lambda ()
	  (type 'del (get))))
      
      (define del-wrapped
	(lambda ()
	  (if wrapped (wrapped 'del))))
      
      (define wrap
	(lambda ()
	  (type 'wrap self)))
      
      (define unwrap
	(lambda ()
	  (type 'unwrap self)))
      
      (if (type 'get-target)
	  (set! wrapped (lwis-var-new (type 'get-target)
				      (lwis-printf "wrap__~a" name))))
      
      self)))



(define lwis-wrapped-func-new
  (lambda (type name paramvars)

    (let ((desc ""))

      (define self
	(lambda args
	  (apply
	   (case (car args)
	     ((get-type) get-type)
	     ((get-name) get-name)
	     ((get-desc) get-desc)
	     ((set-desc) set-desc)
	     ((get-params) get-params)
	     (else (error "No such lwis-wrapped-func method ~s" (car args))))
	   (cdr args))))
      
      (define get-type
	(lambda () type))
      
      (define get-name
	(lambda () name))
      
      (define get-desc
	(lambda () desc))

      (define set-desc
	(lambda (str)
	  (set! desc str)
	  desc))
      
      (define get-params
	(lambda () paramvars))

      (set! paramvars
	    (map (lambda (p) (if (list? p) (apply lwis-var-new p) p))
		 paramvars))

    self)))



(define lwis-wrapped-lib-new
  (lambda (name)
    (let ((funcs '())
	  (hdrs '())
	  (syshdrs '()))
    
      (define self
	(lambda args
	  (apply
	   (case (car args)
	     ((get-name) get-name)
	     ((get-desc) get-desc)
	     ((get-funcs) get-funcs)
	     ((add-func) add-func)
	     ((get-headers) get-hdrs)
	     ((add-header) add-hdr)
	     ((get-sysheaders) get-syshdrs)
	     ((add-sysheader) add-syshdr)
	     (else (error "No such method ~s" (car args))))
	   (cdr args))))

      (define get-name
	(lambda () name))

      (define get-desc
	(lambda () ""))

      (define get-funcs
	(lambda () funcs))

      (define add-func
	(lambda (lwfunc)
	  (set! funcs (cons lwfunc funcs))
	  funcs))

      (define get-hdrs
	(lambda () hdrs))

      (define add-hdr
	(lambda (str)
	  (set! hdrs (cons str hdrs))
	  hdrs))

      (define get-syshdrs
	(lambda () syshdrs))

      (define add-syshdr
	(lambda (str)
	  (set! syshdrs (cons str syshdrs))
	  syshdrs))
      
      self)))


(load "expr.scm")


;; The end.
