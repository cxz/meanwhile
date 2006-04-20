/**
   Sample library with which to test LWIS
*/


#include <stdio.h>
#include <string.h>


int foobar(char *text) {
  if(text) printf(text);
  return 0;
}


int barfoo(char *text) {
  int len = 0;
  if(text) len = strlen(text);
  while(len--) putchar(text[len]);
  return 0;
}


/* The end. */
