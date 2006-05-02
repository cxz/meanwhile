

all:	test.so


wrap_test.c:	test.scm
	./lwis.scm -t python test.scm -o wrap_test.c


test.so: test.c wrap_test.c
	gcc -c --shared test.c wrap_test.c -I/usr/include/python2.4/
	gcc --shared test.o wrap_test.o -L/usr/lib/python2.4/ -o test.so


clean:
	rm -f wrap_test.c
	rm -f *.o *.so

