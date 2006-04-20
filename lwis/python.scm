;; basic python module


;; exression calling Py_INCREF on the wrapped var
(define Py_INCREF
  (lambda (expr)
    (lwis-call "Py_INCREF" `(,expr))))



;; expression calling Py_DECREF on the wrapped var
(define Py_DECREF
  (lambda (expr)
    (lwis-call "Py_DECREF" `(,expr))))



(define PyObject*
  (lwis-target-type-new "PyObject*"))

(PyObject* 'set-dup Py_INCREF)
(PyObject* 'set-del Py_DECREF)


(define PyMethodDef
  (lwis-target-type-new "PyMethodDef"))


(define PyInt_AsLong
  (lambda (expr)
    (lwis-call "PyInt_AsLong" `(,expr))))


(define PyInt_FromLong
  (lambda (expr)
    (lwis-call "PyInt_FromLong" `(,expr))))


(define PyString_AsString
  (lambda (expr)
    (lwis-call "PyString_AsString" `(,expr))))


(define PyString_FromString
  (lambda (expr)
    (lwis-call "PyString_FromString" `(,expr))))



;; expression to parse an args expression into a list of param
;; variables it expects all of the params to have already had their
;; unwrapped versions declared. 
(define PyArgs_ParseTuple
  (lambda (argsexp params)
    
    ;; a weird little string of python parsetuple entries
      ;; todo add an appropriate entry to types for these strings
    (define sob
      (lwis-join "" (map (lambda (param) "O") params)))
    
    
    ;; a list of expressions which evaluate to a pointer to the
    ;; wrapped variable for each necessary param
    (define pob
      (map (lambda (param)
	     (lwis-literal
	      (lwis-printf "&~a" (param 'get-wrapped-name))))
	   params))
    
    (lwis-call "PyArgs_ParseTuple" `(,argsexp
				     ,(lwis-literal-str sob)
				     . ,pob))))



(define py-function
  (lambda (func)

    (lwis-func
     "static" PyObject* (lwis-printf "wrap__~a" (func 'get-name))
     (func 'get-params)
     
     ;; need a return value
     (let ((retvar (lwis-var-new (func 'get-type) "ret")))
       
       (lwis-block
	
	(lwis-expr-list
	 (map (lambda (p) (lwis-stmt (p 'declare)))
	      (func 'get-params)))
	
	(lwis-expr-list
	 (map (lambda (p) (lwis-stmt (p 'declare-wrapped)))
	      (func 'get-params)))
	
	(lwis-newline)
	
	(lwis-stmt (retvar 'declare))
	(lwis-stmt (retvar 'declare-wrapped))

	(lwis-newline)
	
	;; PyArgs_ParseTupleAndKewords
	;; todo add error checking
	(lwis-stmt
	 (PyArgs_ParseTuple (lwis-literal 'args) (func 'get-params)))
	
	(lwis-newline)

	;; unwrap all vars
	(lwis-expr-list
	 (map (lambda (p) (lwis-stmt (p 'set (p 'unwrap))))
	      (func 'get-params)))
	
	(lwis-newline)

	;; call func
	;; I'd like to just do (func 'call) eventually
	(lwis-stmt
	 (retvar 'set (lwis-call (func 'get-name)
				 (map (lambda (param) (param 'get))
				      (func 'get-params)))))
	
	(lwis-newline)

	;; wrap return var
	(lwis-stmt
	 (retvar 'set-wrapped (retvar 'wrap)))
	
	(lwis-newline)
	
	;; release wrapped vars
	(lwis-expr-list
	 (map (lambda (p) (lwis-stmt (p 'del-wrapped)))
	      (func 'get-params)))
	
	(lwis-newline)

	;; return
	(lwis-return-expr (retvar `get-wrapped)))))))


(define py-function-flags
  (lambda (func)
    (lambda (output)
      (if (null? (func 'get-params))
	  (output "PY_METHOD_NOARGS")
	  (output "PY_METHOD_VARARGS")))))


(define py-function-struct
  (lambda (func)
    (lwis-struct
     (lwis-literal-str (func 'get-name))
     (lwis-literal (lwis-printf "wrap__~a" (func 'get-name)))
     (py-function-flags func)
     (lwis-literal-str (func 'get-desc)))))


(define Py_InitModule
  (lambda (module)
    (lwis-call "Py_InitModule3"
	       `(,(lwis-literal-str (module 'get-name))
		 ,(lwis-literal-str
		   (lwis-printf "~a__methods" (module 'get-name)))
		 ,(lwis-literal-str (module 'get-desc))))))


(define py-module-init
  (lambda (module)
    (lwis-func
     "" void (lwis-printf "init_~a" (module 'get-name)) '()
     
     (let ((mod (lwis-var-new PyObject* "mod")))

       (lwis-block
	(lwis-stmt
	 (mod 'declare))

	(lwis-newline)

	(lwis-stmt
	 (mod 'set (Py_InitModule module)))
	
	;; todo: add constants
	;; todo: add types
	;; todo: add classes
	
	)))))


(define py-module
  (lambda (module)
    
    (lwis-exprs

     ;; headers
     ;; todo

     ;; define all the functions we're wrapping
     (lwis-expr-list
      (map py-function (module 'get-funcs)))

     (lwis-newline)

     ;; define all the simple types

     ;; define all the classes

     ;; the functions (module methods) structure
     (let ((funclist (lwis-var-new
		      PyMethodDef
		      (lwis-printf "~a__methods" (module 'get-name)))))

       (funclist 'set-flags "static")
       
       (lwis-array-declare-literal
	funclist
	(lwis-array-list (map py-function-struct (module 'get-funcs)))))
     
     (lwis-newline)
     
     ;; module init function
     (py-module-init module)

     (lwis-newline)
     )))


;(define Python
;  (lwis-target "python" py-module))


;; The end.
