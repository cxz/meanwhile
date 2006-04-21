;; some standard C type definitions for Python


(require "glibc.scm")
(require "python.scm")



;; no argument, 
(define void
  (lwis-type-new
   "void" PyObject*
   (lambda (var)
     (lwis-exprs
      (lwis-stmt (Py_INCREF Py_None))
      (lwis-stmt (var 'set-wrapped Py_None))))
   lwis-noop))

(void 'set-declare lwis-noop)
(void 'set-setter (lambda (var expr) expr))
(void 'set-getter Py_None_INCREF)


;; generic pointer
(define void*
  (lwis-type-new
   "void*" PyObject*
   (lambda (var)
     (lwis-stmt (var 'set-wrapped (PyCObject_FromVoidPtr (var 'get)))))
   (lambda (var)
     (lwis-stmt (var 'set (PyCObject_AsVoidPtr (var 'get-wrapped)))))))


(define int
  (lwis-type-new
   "int" PyObject*
   (lambda (var)
     (lwis-stmt (var 'set-wrapped (PyInt_FromLong (var 'get)))))
   (lambda (var)
     (lwis-stmt (var 'set (PyInt_AsLong (var 'get-wrapped)))))))



(define uint
  (lwis-type-new
   "unsigned int" PyObject*
   (lambda (var)
     (lwis-stmt (var 'set-wrapped (PyInt_FromLong (var 'get)))))
   (lambda (var)
     (lwis-stmt (var 'set (PyInt_AsLong (var 'get-wrapped)))))))



(define char*
  (lwis-type-new
   "char*" PyObject*

   ;; wrap char* to PyObject*
   (lambda (var)
     (lwis-stmt
      (var 'set-wrapped (PyString_FromString (var 'get)))))

   ;; unwrap PyObject* into char*
   (lambda (var)
     (lwis-exprs
      (lwis-stmt (var 'set (PyString_AsString (var 'get-wrapped))))
      (lwis-stmt (var 'set (strdup (var 'get))))))))


(char* 'set-del free)



(define const-char*
  (lwis-type-new
   "const char*" PyObject*

   ;; wrap const char* to PyObject*
   (lambda (var)
     (lwis-stmt
      (var 'set-wrapped (PyString_FromString (strdup (var 'get))))))

   ;; unwrap PyObject* into const char*
   (lambda (var)
     (lwis-stmt
      (var 'set (PyString_AsString (var 'get-wrapped)))))))



;; The end.
