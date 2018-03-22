#include "getch.h"

int main(int argc, char *argv[]){
    char key[16];
    get_keypress(key, 0);
    find_key(key);
    
    return 0;
}
