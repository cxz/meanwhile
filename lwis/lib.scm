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


(define lwis-newline
  (lambda ()
    (lambda (output) (output "\n"))))


;; expression with no output
(define lwis-noop
  (lambda args
    (lambda (output) #t)))


;; expression of operand applied between two expressions
(define lwis-op
  (lambda (op expr1 expr2)
    (lambda (output)
      (output (lwis-printf
	       "~a ~a ~a"
	       (lwis-expr-eval expr1)
	       op
	       (lwis-expr-eval expr2))))))


(define lwis+
  (lambda (expr1 expr2)
    (lwis-op '+ expr1 expr2)))


(define lwis-
  (lambda (expr1 expr2)
    (lwis-op '- expr1 expr2)))


(define lwis,
  (lambda (expr1 expr2)
    (lwis-op "," expr1 expr2)))


(define lwis=
  (lambda (expr1 expr2)
    (lwis-op "=" expr1 expr2)))


;; simple formatted string substitution
(define lwis-printf
  (lambda args
    (apply format `(,#f . ,args))))



;; evaluates an expression to a string
(define lwis-expr-eval
  (lambda (expr)

    (let ((res '()))
      (let ((fo (lambda (r) (set! res (append res `(,r))))))

	(cond
	 ((string? expr)
	  ((lwis-literal-str expr) fo))
	 ((number? expr)
	  ((lwis-literal expr) fo))
	 (else (expr fo))))

      (lwis-join "" res))))


(define lwis-exprs-eval
  (lambda exprs
    (lwis-expr-eval (lwis-expr-list exprs))))


(define lwis-expr-printf-eval
  (lambda (expr frmt)
    (let ((res '()))
      (expr (lwis-printf-output
	     (lambda (r) (set! res (append res `(,r)))) frmt))
      (lwis-join "" res))))


;; an wrapping output function that does printf formatting
(define lwis-printf-output
  (lambda (old-output frmt)
    (lambda (s) (old-output (lwis-printf frmt s)))))



(define lwis-indent-output
  (lambda (old-output)
    (lwis-printf-output old-output "  ~a")))



;; a wrapping output function that appends a semi-colon
(define lwis-stmt-output
  (lambda (old-output)
    (lwis-printf-output old-output "~a;\n")))


(define lwis-not
  (lambda (expr)
    (lambda (output)
      (output (lwis-printf "! ~a" (lwis-expr-eval expr))))))


(define lwis-join-f
  (lambda (s l f)
    (cond
     ((null? l) "")
     ((null? (cdr l))
      (lwis-printf "~a" (f (car l))))
     (else
      (lwis-printf "~a~a~a" (f (car l)) s (lwis-join-f s (cdr l) f))))))



;; joins a list around a string
(define lwis-join
  (lambda (s l) (lwis-join-f s l (lambda (a) a))))



;; joins the evaluated expressions in list around a string
(define lwis-join-eval
  (lambda (s l) (lwis-join-f s l lwis-expr-eval)))



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
	  (type 'wrap (get))))
      
      (define unwrap
	(lambda ()
	  (type 'unwrap (get-wrapped))))
      
      (if (type 'get-target)
	  (set! wrapped (lwis-var-new (type 'get-target)
				      (lwis-printf "wrap__~a" name))))
      
      self)))


(define lwis-array-declare-sized
  (lambda (var expr_s)
    (lambda (output)
      (output (lwis-printf "~a[~a]"
			   (lwis-expr-eval (var 'declare))
			   (lwis-expr-eval expr_s))))))


(define lwis-array-declare-literal
  (lambda (var expr)
    (lambda (output)
      (output (lwis-printf "~a[] = ~a;\n"
			   (lwis-expr-eval (var 'declare))
			   (lwis-expr-eval expr))))))


(define lwis-array-get
  (lambda (var expr_i)
    (lambda (output)
      (output (lwis-printf "~a[~a]"
			   (lwis-expr-eval (var 'get))
			   (lwis-expr-eval expr_i))))))


(define lwis-array-set
  (lambda (var expr_i expr_val)
    (lambda (output)
      (output (lwis-printf "~a[~a] = ~a"
			   (lwis-expr-eval (var 'get))
			   (lwis-expr-eval expr_i)
			   (lwis-expr-eval expr_val))))))


(define lwis-block-list
  (lambda (exprs) 
    (let ((el (lwis-expr-list exprs)))
      (lambda (output)
	(output "{\n")
	(el (lwis-indent-output output))
	(output "}\n")))))


;; expression that is an indented block of sub-expressions wrapped in
;; sexy-braces
(define lwis-block
  (lambda exprs (lwis-block-list exprs)))


;; combines multiple expressions into a single expression
(define lwis-expr-list
  (lambda (exprs)
    (lambda (output)
      (let next ((e exprs))
	(if (not (null? e))
	    (begin
	      ((car e) output)
	      (next (cdr e))))))))



(define lwis-exprs
  (lambda exprs
    (lwis-expr-list exprs)))



;; literal string expression
(define lwis-literal
  (lambda (a)
    (lambda (output) (output (lwis-printf "~a" a)))))


(define lwis-literal-str
  (lambda (a)
    (lambda (output) (output (lwis-printf "~s" a)))))


;; an expression wrapping another expression in parenthesis
(define lwis-paren
  (lambda (expr)
    (lambda (output)
      (output (lwis-printf "(~a)" (lwis-expr-eval expr))))))


;; an expression that writes a function declaration
(define lwis-func
  (lambda (flags type name paramvars block)
    (lambda (output)

      (output (lwis-printf
	       (if (string=? "" flags) "~a~a ~a(~a)" "~a ~a ~a(~a)")
	       
	       flags (type 'get-name) name
	       (lwis-join ", "
			  (map (lambda (p) (lwis-expr-eval (p 'declare)))
			       paramvars))))
      (block output))))



(define lwis-wrapped-func-new
  (lambda (type name paramvars)

    (define self
      (lambda args
	(apply
	 (case (car args)
	   ((get-type) get-type)
	   ((get-name) get-name)
	   ((get-desc) get-desc)
	   ((get-params) get-params)
	   (else (error "No such method ~s" (car args))))
	 (cdr args))))

    (define get-type
      (lambda () type))

    (define get-name
      (lambda () name))

    (define get-desc
      (lambda () ""))

    (define get-params
      (lambda () paramvars))

    self))



(define lwis-wrapped-lib-new
  (lambda (name)
    (let ((funcs '()))
    
      (define self
	(lambda args
	  (apply
	   (case (car args)
	     ((get-name) get-name)
	     ((get-desc) get-desc)
	     ((get-funcs) get-funcs)
	     ((add-func) add-func)
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
      
      self)))



(define lwis-array-list
  (lambda (exprs)
    (let ((el (lwis-expr-list exprs)))
      (lambda (output)
	(output "{\n")
	(el (lwis-printf-output output "  ~a,\n"))
	(output "}")
	))))



(define lwis-array
  (lambda exprs
    (lwis-array-list exprs)))



(define lwis-struct-list
  (lambda (exprs)
    (lambda (output)
      (output (lwis-printf "{ ~a }" (lwis-join-eval ", " exprs))))))



(define lwis-struct
  (lambda exprs
    (lwis-struct-list exprs)))



;; expression that is a stand-alone statement (ends in a ;)
(define lwis-stmt
  (lambda (expr)
    (lambda (output)
      (expr (lwis-stmt-output output)))))



;; expression of a function call, given a name and list of expressions
;; as arguments
(define lwis-call
  (lambda (name exprs)
    (lambda (output)
      (output 
       (lwis-printf "~a(~a)" name (lwis-join-eval ", " exprs))))))



;; expression of a return statement, returning another expression
(define lwis-return-expr
  (lambda (expr)
    (lambda (output)
      (expr (lwis-printf-output output "return ~a;\n")))))
      


;; expression of a return statement
(define lwis-return
  (lambda ()
    (lambda (output)
      (output "return;\n"))))


(define lwis-sysheader
  (lambda (name)
    (lambda (output)
      (output (lwis-printf "#include <~a>\n" name)))))


(define lwis-header
  (lambda (name)
    (lambda (output)
      (output (lwis-printf "#include \"~a\"\n" name)))))


(define NULL
  (lwis-literal "(void*)0"))


;; todo: rewrite this bastard
(define lwis-if
  (lambda (expr_test expr_then)
    (lambda (output)
      (output (lwis-printf "if(~a) {\n" (lwis-expr-eval expr_test)))
      (expr_then (lwis-indent-output output))
      (output "}\n"))))


;; The end.
