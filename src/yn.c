#include <strings.h>
#include <stdlib.h>
#include <errno.h>
#include "getch.h"
#include "echo.h"

int main(int argc, char *argv[]){
    struct termios t;

    /* Terminate if stdio is not a terminal */
    if ((tcgetattr(STDIN_FILENO, &t) < 0) |! (isatty(0)))
        return EXIT_FAILURE;

    /* echo argv as prompt */
    if (argc > 1) {
        --argc;
        ++argv;
        echo_escape_argv(argc, argv, stderr);
    }

    /* Esc C-g C-d C-q C-x */
    char *cancel = "\e\x07\x04\x11\x18"; 
    char key[16];
    size_t match = 1;

    while (1) {
        get_keypress(key, 0);

        if (strcasecmp(key ,"y") == 0) {
            putchar(key[0]);
            return EXIT_SUCCESS;
        }

        if (strcasecmp(key ,"n") == 0) {
            putchar(key[0]);
            return EXIT_FAILURE;
        }
        
        match = strcspn(key, cancel);
        if (!match)
            return ECANCELED;
    } 

    return EXIT_FAILURE;
}
