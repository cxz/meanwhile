;; expression utilities


;; simple formatted string substitution
(define lwis-printf
  (lambda args
    (apply format `(,#f . ,args))))


;; an wrapping output function that does printf formatting
(define lwis-printf-output
  (lambda (old-output frmt)
    (lambda (s) (old-output (lwis-printf frmt s)))))



(define lwis-indent-output
  (lambda (old-output)
    (lwis-printf-output old-output "  ~a")))




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



;; a wrapping output function that appends a semi-colon
(define lwis-stmt-output
  (lambda (old-output)
    (lwis-printf-output old-output "~a;\n")))


(define lwis-not
  (lambda (expr)
    (lambda (output)
      (output (lwis-printf "! ~a" (lwis-expr-eval expr))))))



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
  (lambda exprs
    (lwis-block-list exprs)))



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
