;; my test lib


(require "glibc-python.scm")


;; todo: specify lwis modules by name. the target-specific versions
;; will get loaded as well
;(lwis-use "libc")



(define test-lib
  (lwis-wrapped-lib-new "test"))


;; add the header test.h to the wrapped lib
(test-lib 'add-header "test.h")



;; function foobar
(define test-foobar
  (lwis-wrapped-func-new
   ;; return type
   void

   ;; c-name
   "foobar"

   ;; list of lwis-var parameters
   `(,(const-char* "text"))))

;; set the description
(test-foobar
 'set-desc
 "this is a test function that will print text to stdout")

;; add foobar to the wrapped library
(test-lib 'add-func test-foobar)



;; function barfoo
(define test-barfoo
  (lwis-wrapped-func-new
   void "barfoo" `(,(const-char* "txet"))))

(test-barfoo
 'set-desc
 "this is a test function that will print text backwards to stdout")

(test-lib 'add-func test-barfoo)



;; example of something crazy. the reverse implementation modifies
;; text in place, then returns it. Even though the actual function
;; definition is reverse(char*):char*, we're going to pretend it
;; returns a const-char* instead. Otherwise the duplicated unwrapped
;; char* which will be the basis for the PyString will get free'd.
;; With our modifications, it'll be copied before made into a PyString

(define test-reverse
  (lwis-wrapped-func-new
   const-char* "reverse" `(,(char* "text"))))

(test-lib 'add-func test-reverse)



;; function const_reverse
(define test-const-reverse
  (lwis-wrapped-func-new
   const-char* "const_reverse" `(,(const-char* "text"))))

(test-lib 'add-func test-const-reverse)



;; todo:
;(define TestPoint
;  (lwis-class-new
;   "struct test_point*" "TestPoint" PyObject*
;   `(,(int "x")
;     ,(int "y"))
;   ))
;
;
;
;(define TestLine
;  (lwis-class-new
;   "struct test_line*" "TestLine" PyObject*
;   `(,(TestPoint "start")
;     ,(TestPoint "end"))
;   ))



;; todo: replace this with (lwis-target 'add-lib test-lib)
((py-module test-lib) display)



;; The end.
