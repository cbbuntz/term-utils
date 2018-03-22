#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

inline static int
hex2bin (unsigned char c)
{
    if (c <= '9')
        return c - '0';
    else
        return (0b11011111 & c) - 'A' + 10;
}

#define echo_dump(STR, OUT) fputs (STR, OUT)
#define eecho(STR) fputs (STR, stderr)

void
echo_escape(char *str, FILE* output) {
   char c;
    
   while ((c = *str) && (c != '\\')){
       fputc(*str, output);
       str++;
   };
   
   if (c != '\\')
       return;

   if(*++str) {
       c = *str;
       switch (c) {
           case '0' : return;
           case '\0': return;
           case 'a' : c = '\a'; break;
           case 'b' : c = '\b'; break;
           case 'c' : exit(EXIT_SUCCESS);
           case 'e' : c = '\e'; break;
           case 'f' : c = '\f'; break;
           case 'n' : c = '\n'; break;
           case 'r' : c = '\r'; break;
           case 't' : c = '\t'; break;
           case 'v' : c = '\v'; break;
           case '"' : c = '"' ; break;
           case '\'': c = '\''; break;
           case '\\': c = '\\'; break;
           case 'x' : str++;
                      if (! isxdigit (*str))
                          break;

                      c = hex2bin(*str);
                      
                      if ((++str) && (isxdigit(*str)))
                          c = (c << 4) + hex2bin(*str);

                      break;
           default : c = '\\'; break;
       }

       fputc(c, output);
       
       if(*++str) {
           echo_escape(str, output);
       }
   }
}

void
echo_dump_argv(int argc, char *argv[], FILE *output){
    while (argc > 0)
    {
        fputs (argv[0], output);
        argc--;
        argv++;
        if (argc > 0)
            fputc(' ', output);
    }
}

void
echo_escape_argv(int argc, char *argv[], FILE *output){
    while (argc > 0)
    {
        echo_escape(argv[0], output);
        argc--;
        argv++;
        if (argc > 0)
            fputc (' ', output);
    }
}

