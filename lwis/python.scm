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
  (lwis-type-new "PyObject*" #f))

(PyObject* 'set-dup Py_INCREF)

(PyObject* 'set-del Py_DECREF)



(define Py_None
  (PyObject* "Py_None"))



(define Py_None_INCREF
  (lambda args_ignored
    (lwis-paren (lwis, (Py_None 'dup) (Py_None 'get)))))



(define PyMethodDef
  (lwis-type-new "PyMethodDef" #f))



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
(define PyArg_ParseTuple
  (lambda (args params)
    
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
    
    (lwis-call "PyArg_ParseTuple" `(,(args 'get)
				     ,(lwis-literal-str sob)
				     . ,pob))))



(define py-function
  (lambda (func)

    (let ((retvar ((func 'get-type) "ret"))
	  (self (PyObject* "self"))
	  (args (PyObject* "args")))

      (lwis-func
       "static" PyObject* (lwis-printf "wrap__~a" (func 'get-name))
       `(,self ,args)
       
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
	
	;; PyArg_ParseTupleAndKewords
	;; todo add error checking
	(lwis-if
	 (lwis-not (PyArg_ParseTuple args (func 'get-params)))
	 (lwis-return-expr NULL))
	
	(lwis-newline)

	;; unwrap all vars
	(lwis-expr-list
	 (map (lambda (p) (p 'unwrap))
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
	(retvar 'wrap)
	
	(lwis-newline)
       
	;; del unwrapped vars
	(lwis-expr-list
	 (map (lambda (p) (lwis-stmt (p 'del)))
	      (func 'get-params)))

	(lwis-newline)

	;; return
	(lwis-return-expr (retvar `get-wrapped)))))))



(define METH_NOARGS
  (lwis-literal "METH_NOARGS"))



(define METH_VARARGS
  (lwis-literal "METH_VARARGS"))



(define py-function-flags
  (lambda (func)
    (if (null? (func 'get-params))
	METH_NOARGS METH_VARARGS)))



(define py-function-struct
  (lambda (func)
    (lwis-struct
     (func 'get-name)
     (lwis-literal (lwis-printf "wrap__~a" (func 'get-name)))
     (py-function-flags func)
     (func 'get-desc))))



(define Py_InitModule
  (lambda (module)
    (lwis-call "Py_InitModule3"
	       `(,(module 'get-name)
		 ,(lwis-literal
		   (lwis-printf "~a__methods" (module 'get-name)))
		 ,(module 'get-desc)))))



(define py-module-init
  (lambda (module)
    (lwis-func
     "" void (lwis-printf "init~a" (module 'get-name)) '()
     
     (let ((mod (PyObject* "mod")))

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

     ;; the Python headers
     (lwis-sysheader "Python.h")

     ;; module headers
     (lwis-expr-list
      (map lwis-sysheader (module 'get-sysheaders)))
     (lwis-expr-list
      (map lwis-header (module 'get-headers)))

     (lwis-newline)

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
	(lwis-array-list
	 (append (map py-function-struct (module 'get-funcs))
		 `(,(lwis-struct NULL NULL 0 NULL))))))
     
     (lwis-newline)
     
     ;; module init function
     (py-module-init module)

     (lwis-newline)
     )))



;(define Python
;  (lwis-target "python" py-module))



;; The end.
