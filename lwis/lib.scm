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



(define lwis-type-new
  (lambda (cname super)

    (define _getter
      (lambda (var)
	(lwis-literal (var 'get-name))))

    (define _setter
      (lambda (var expr)
	(lwis= (lwis-literal (var 'get-name)) expr)))
    
    (define _declare
      (lambda (var)
	(lwis-literal
	 (lwis-printf
	  (if (string=? "" (var 'get-flags)) "~a~a ~a" "~a ~a ~a")
	  (var 'get-flags) ((var 'get-type) 'get-name) (var 'get-name)))))

    (let ((target #f)
	  (dup lwis-noop)
	  (del lwis-noop)
	  (getter _getter)
	  (setter _setter)
	  (decl _declare)
	  (wrap lwis-noop)
	  (unwrap lwis-noop))

      (define self
	(lambda args
	  (apply
	   (case (car args)
	     ((get-name) (lambda () cname))
	     ((get-target) (lambda () target))
	     ((set-target) (lambda (t) (set! target t)))
	     ((get-dup) (lambda () dup))
	     ((set-dup) (lambda (f) (set! dup f)))
	     ((dup) dup)
	     ((get-del) (lambda () del))
	     ((set-del) (lambda (f) (set! del f)))
	     ((del) del)
	     ((get-getter) (lambda () getter))
	     ((set-getter) (lambda (f) (set! getter f)))
	     ((get) getter)
	     ((get-setter) (lambda () setter))
	     ((set-setter) (lambda (f) (set! setter f)))
	     ((set) setter)
	     ((get-decl) (lambda () decl))
	     ((set-decl) (lambda (f) (set! decl f)))
	     ((declare) decl)
	     ((get-wrap) (lambda () wrap))
	     ((set-wrap) (lambda (f) (set! wrap f)))
	     ((wrap) wrap)
	     ((get-unwrap) (lambda () unwrap))
	     ((set-unwrap) (lambda (f) (set! unwrap f)))
	     ((unwrap) unwrap)
	     (else
	      (if (string? (car args))
		  (lambda () (new-var (car args)))
		  (error "No such method in lwis-type: " (car args)))))

	   (cdr args))))
      
      (define new-var
	(lambda (name)
	  (lwis-var-new self name)))

      (if super
	  (begin
	    (set! target (super 'get-target))
	    (set! dup (super 'get-dup))
	    (set! getter (super 'get-getter))
	    (set! setter (super 'get-setter))
	    (set! decl (super 'get-decl))
	    (set! wrap (super 'get-wrap))
	    (set! unwrap (super 'get-unwrap))))

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
	     (else (error "No such method in lwis-var: " (car args))))
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
