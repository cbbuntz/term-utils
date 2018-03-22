#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <fcntl.h>
#include <unistd.h>
#include "keysym.h"

int find_key(char* key){
  int len = strlen(key);
  int n = sizeof(KEYMAP) / sizeof(keymap);
  if (len == 1){
    if (key[0] < ' '){
      if (key[0] == '\x0A') {
        printf("LF\n");
      } else if (key[0] == '\x09') {
        printf("TAB\n");
      } else {
        printf("C-%s\n", keysym[key[0] + '@']);
      }
      return key[0];

    } else {
      // for (int i = 0; i < n; i++) {
      // if (!strcmp(key, KEYMAP[i].seq)){
      printf("%s\n", keysym[(unsigned)key[0]]);
      return key[0];

    }
  } else if (len == 2) {
    printf("M-%s\n", keysym[(unsigned)key[1]]);
    return 0;
  }
  else {
    for (int i = 0; i < n; i++) {
      if (!strcmp(key, KEYMAP[i].seq)){
        printf("%s\n", KEYMAP[i].name);
        return i;
      }
    }

  }
  printf("\?\n");
  return -1;
}

static struct termios old_termios, new_termios;
static void init_termios(int echo) {
    tcgetattr(0, &old_termios);
    new_termios = old_termios;
    if (!echo) new_termios.c_lflag &= ~ECHO;
    new_termios.c_lflag &= ~ICANON;
    tcsetattr(0, TCSANOW, &new_termios);
}

static void reset_termios(void) {
    tcsetattr(0, TCSANOW, &old_termios);
}

char getch(int echo) {
    char ch;
    init_termios(echo);
    ch = getchar();
    reset_termios();
    return ch;
}

char getch_nonblock(int echo) {
    char ch;
    int old_termiosf;
    init_termios(echo);
    old_termiosf = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, old_termiosf | O_NONBLOCK);
    ch = getchar();
    reset_termios();
    fcntl(STDIN_FILENO, F_SETFL, old_termiosf & O_NONBLOCK);
    return ch;
}

int get_keypress(char *s, int echo) {
    int len = 0;
    char c = getch(echo);
    do {
        s[len] = c;
        len++;
        c = getch_nonblock(echo);
    } while(c != -1);

    s[len] = '\0';

    return len;
}
