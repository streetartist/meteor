/* gonert.c

   This file contains runtime support functions for the Gone language
   as well as boot-strapping code related to getting the main program
   to run.
*/

#include <stdio.h>

// __declspec(dllexport)      // Uncomment on Windows
void _print_int(int x) {
  printf("%i\n", x);
}

// __declspec(dllexport)     // Uncomment on Windows
void _print_float(double x) {
  printf("%f\n", x);
}


// __declspec(dllexport)    // Uncomment on Windows
void _print_byte(char c) {
  printf("%c", c);
  fflush(stdout);
}

/* Bootstrapping code for a stand-alone executable */

#ifdef NEED_MAIN
extern void __gone_init(void);
extern int __gone_main(void);

int main() {
  __gone_init();
  return __gone_main();
}
#endif
