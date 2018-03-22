/*
 * same as `say`, but dumps raw, backslashed characters
 * instead of escape sequences
 */ 

#include <termios.h>
#include <unistd.h>
#include "cat.h"
#include "echo.h"

int main(int argc, char **argv) {
    if (argc > 1) {
        --argc;
        ++argv;
        echo_dump_argv(argc, argv, stdout);
    }

    struct termios t;
    if (tcgetattr(STDIN_FILENO, &t) < 0)
        cat_dump(stdout);
    
  return 0;
}
