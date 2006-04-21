;; my test lib


(load "lib.scm")
(require "glibc-python.scm")


(define test-lib
  (lwis-wrapped-lib-new "test"))

(test-lib 'add-header "test.h")


(define test-foobar
  (lwis-wrapped-func-new
   void "foobar" `((,const-char* "text"))))

(test-foobar
 'set-desc
 "this is a test function that will print text to stdout")

(test-lib 'add-func test-foobar)


(define test-barfoo
  (lwis-wrapped-func-new
   void "barfoo" `((,const-char* "txet"))))

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
   const-char* "reverse" `((,char* "text"))))

(test-lib 'add-func test-reverse)


(define test-const-reverse
  (lwis-wrapped-func-new
   const-char* "const_reverse" `((,const-char* "text"))))

(test-lib 'add-func test-const-reverse)


;(define TestPoint
;  (lwis-class-new
;   "struct test_point*" "TestPoint" PyObject*
;   `((,int "x")
;     (,int "y"))
;   ))
;
;
;(define TestLine
;  (lwis-class-new
;   "struct test_line*" "TestLine" PyObject*
;   `((,TestPoint "start")
;     (,TestPoint "end"))
;   ))


;; todo replace this with (lwis-target 'add-lib test-lib)
((py-module test-lib) display)


;; The end.
