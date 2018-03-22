#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "raw_chars.h"

// typical, buffered implementation
void cat(FILE *output) {
	char buf[BUFSIZ];
	long n;
	while((n = read(0, buf, (long)sizeof buf))>0)
	    fputs(buf, output);
}
    
// character-wise
void catc(FILE *output) {
	char c;
	while((c = fgetc(stdin)) != EOF){
	    fputc(c, stdout);
	}
}

// dump raw chars. 
// there is probably a better solution 
// than a LUT.
void cat_dump(FILE *output) {
	char c;
	while((c = fgetc(stdin)) != EOF){
	    if ((c < ' ') || (c == 127))
	        fputs(raw_char[(unsigned)c], stdout);
	      else
	          fputc(c, stdout);
	}
}

// line-wise
int cat_lines(FILE *output) {
    char buf[BUFSIZ];
    while ( (fgets(buf, sizeof buf, stdin)) )
        fputs(buf, output);
    
    return 0;
}


int cat_linenum() {
    char buf[BUFSIZ];
    char *s;
    int count = 0;
    while ( (s = fgets(buf, sizeof buf, stdin)) )
    {
        count += 1;
        printf("%3d: %s", count, buf);
    }
    return count;
}
