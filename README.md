# term-utils

### Collection of simple terminal utilities

C binaries and corresponding modular headers for drop-in functionality.


* **say**
A hybrid of `echo` and `cat`  
It prints the argument vector, similar to `echo -n`, then it prints any text piped to it, similar to `cat`, but unlike `cat`, it will not block when no input is given.  It may be useful in certain scripting situations when you aren't sure where the input is going to come from.  

* **dump**
same as `say`, but dumps raw input instead of processed escape sequences.

* **getch**
Nonblocking `getchar()` for use in a shell. Automatically captures escape sequences and can translate them to human-readable names if desired

* **yn**
Based on `getch`, but waits for a 'y' or 'n' and returns EXIT_SUCCESS or EXIT_FAILURE respectively. Automatically terminates if stdin is not a tty. If an argv is provided, it is echoed through stderr.  
Example usage: `yn 'Continue?' && rm $filename`

### Miscellaneous scripts* **Markdown rendering**  
![markdown renderer preview](https://raw.githubusercontent.com/cbbuntz/term-utils/master/markdown/md_parse.png)

A collection of experimental ruby scripts. Makes markdown look good even in a terminal. Many bits from [legion_hacker](https://github.com/cbbuntz/legion_hacker/) were repurposed for this.  
Also includes a generic syntax highlighter, which in turn has the beginnings an automatic language detector.

* **gpaste-dmenu**
`dmenu` wrapper for fuzzy searching clipboard history and selecting

* **volume_remap_to_keys**
[`dmenu`](https://tools.suckless.org/dmenu/) wrapper of `xmodmap` to remap the volume control to different keypresses. Useful if your keyboard has a volume roller, so you can send a series of up / down keypresses by rolling it up and down. Not just for terminals, but it's fun to use with text editors. Also good for adding a scroll wheel to your keyboard.

