;; my test lib


(load "lib.scm")
(require "glibc-python.scm")


(define test-lib
  (lwis-wrapped-lib-new "test"))


(define test-foobar
  (lwis-wrapped-func-new
   void "foobar" `(,(lwis-var-new char* "text"))))

;(test-foobar
; 'set-desc
; "this is a test function that will print text to stdout")

(test-lib 'add-func test-foobar)


(define test-barfoo
  (lwis-wrapped-func-new
   void "barfoo" `(,(lwis-var-new char* "txet"))))

;(test-barfoo
; 'set-desc
; "this is a test function that will print text backwards to stdout")

(test-lib 'add-func test-barfoo)


((py-module test-lib) display)


;; The end.
