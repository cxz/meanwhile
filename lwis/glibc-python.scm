;; some standard C type definitions for Python


(require "glibc.scm")
(require "python.scm")


(define void
  (lwis-type-new
   "void" PyObject*
   lwis-noop lwis-noop))


(define int
  (lwis-type-new
   "int" PyObject*
   PyInt_FromLong PyInt_AsLong))


(define uint
  (lwis-type-new
   "unsigned int" PyObject*
   PyInt_FromLong PyInt_AsLong))


(define char*
  (lwis-type-new
   "char*" PyObject*
   PyString_FromString PyString_AsString))

(char* 'set-dup strdup)
(char* 'set-del free)


;; The end.
