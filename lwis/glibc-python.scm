;; some standard C type definitions for Python



(require "glibc.scm")
(require "python.scm")



(define void (lwis-type-new "void" #f))

(void 'set-decl lwis-noop)

(void 'set-target PyObject*)

(void 'set-getter lwis-noop)

(void 'set-setter (lambda (var expr) expr))

(void 'set-wrap
      (lambda (var)
	(lwis-exprs
	 (lwis-stmt (Py_None 'dup))
	 (lwis-stmt (var 'set-wrapped (Py_None 'get))))))



(define void* (lwis-type-new "void*" #f))

(void* 'set-target PyObject*)

(void* 'set-wrap
       (lambda (var)
	 (lwis-stmt (var 'set-wrapped (PyCObject_FromVoidPtr (var 'get))))))

(void* 'set-unwrap
       (lambda (var)
	 (lwis-stmt (var 'set (PyCObject_AsVoidPtr (var 'get-wrapped))))))



(define int (lwis-type-new "int" void*))

(int 'set-wrap
     (lambda (var)
       (lwis-stmt (var 'set-wrapped (PyInt_FromLong (var 'get))))))

(int 'set-unwrap
     (lambda (var)
       (lwis-stmt (var 'set (PyInt_AsLong (var 'get-wrapped))))))



(define uint (lwis-type-new "unsigned int" int))



(define unsigned-int uint)



(define char* (lwis-type-new "char*" void*))

(char* 'set-wrap
       (lambda (var)
	 (lwis-stmt (var 'set-wraped (PyString_FromString (var 'get))))))

(char* 'set-unwrap
       (lambda (var)
	 (lwis-exprs
	  (lwis-stmt (var 'set (PyString_AsString (var 'get-wrapped))))
	  (lwis-stmt (var 'set (strdup (var 'get)))))))

(char* 'set-dup strdup)

(char* 'set-del free)



(define const-char* (lwis-type-new "const char*" void*))

(const-char*
 'set-wrap 
 (lambda (var)
   (lwis-stmt (var 'set-wrapped (PyString_FromString (strdup (var 'get)))))))

(const-char*
 'set-unwrap
 (lambda (var)
   (lwis-stmt (var 'set (PyString_AsString (var 'get-wrapped))))))

(const-char* 'set-dup strdup)



;; The end.
