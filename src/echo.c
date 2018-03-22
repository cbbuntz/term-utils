#include "echo.h"

int
main(int argc, char *argv[]){
    if (argc < 2) return EXIT_SUCCESS;
    --argc;
    ++argv;
    
    echo_escape_argv(argc, argv, stdout);
    fputc ('\n', stdout);

    return EXIT_SUCCESS;
}

