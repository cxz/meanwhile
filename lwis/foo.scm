

(load "lib.scm")


(require "glibc-python.scm")


(define my-add-eight
  (let ((a (lwis-var-new int 'a)) 
	(b (lwis-var-new char* 'b)))

    (lwis-wrapped-func-new
     int "my_add_eight" `(,a ,b))))


(define mystuff
  (lwis-wrapped-lib-new "mystuff"))


(mystuff 'add-func my-add-eight)


((py-module mystuff) display)


;; The end.
