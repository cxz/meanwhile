/**
   Sample library with which to test LWIS
*/


#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "test.h"


void foobar(const char *text) {
  if(text) printf(text);
}


void barfoo(const char *text) {
  int len = 0;
  if(text) len = strlen(text);
  while(len--) putchar(text[len]);
}


char *reverse(char *text) {
  int a, b = 0;
  if(text) a = strlen(text);

  while(a--) {
    a^=b; b^=a; a^=b;
    text[a] ^= text[b];
    text[b] ^= text[a];
    text[a] ^= text[b];
    b++;
  }

  return text;
}


const char *const_reverse(const char *text) {
  static char ret[1024];
  int len = 0;
  if(text) len = strlen(text);
  strncpy(ret, text, (len > 1023)? 1023: len);
  return reverse(ret);
}


/* The end. */
