/*
 * Hybrid of `echo` and `cat`
 * 
 * It prints the argument vector, similar to `echo -n`,
 * then it prints any text piped to it, similar to `cat`,
 * but unlike `cat`, it will not block when no input is given.
 * 
 * It can be useful in certain scripting situations when you
 * aren't sure where the input is going to come from.
 * 
 */ 

#include <termios.h>
#include <unistd.h>
#include "cat.h"
#include "echo.h"

int main(int argc, char **argv) {
    if (argc > 1) {
        --argc;
        ++argv;
        echo_escape_argv(argc, argv, stdout);
    }

    struct termios t;
    if (tcgetattr(STDIN_FILENO, &t) < 0)
        cat(stdout);
    
  return 0;
}
