require './code_parse'

@style_expr = {
  italic: [/(\*{1})(([^*]+|\\\*)+)(\*{1})/, "\e[3m\\2\e[23m"],
  bold: [/(\*\*)(([^*]+|\\\*)+)(\*\*)/, "\e[1m\\2\e[21m"],
  italic_: [/(_)(([^_]+|\\\*)+)(_)/, "\e[3m\\2\e[23m"],
  bold_: [/(__)(([^_]+|\\\*)+)(__)/, "\e[1m\\2\e[21m"],
  strikeout: [/(~~)(([^*]+|\\\*)+)(~~)/, "\e[9m\\2\e[29m"],
  header1: [/^#/, "\e[1m\\2\e[21m"],
  paragraph: [/^\s*\n/, "\n"],
}

@links = []
@left_margin = 2

@colors = {
  code: color(:truecolor, 0xF8F8F2, 0x1D1F21),
  operator: color(:truecolor_fg, 0x92C5F7),
  paren: color(:truecolor_fg, 0x888888),
  default: "\e[39;49m"
}

def md_code_syntax_hl(s)
  # s.gsub!(/[\[\](){}\.,:;\^|&<>=+\-?]+/, "\e[32m\\0\e[39m")
  # s.gsub!(/(?<!\e)[(){}\[\]]/, "#{@colors[:paren]}\\&\e[39m")
  s.gsub!(/[,.;:\^|&=]+/, "#{@colors[:operator]}\\&\e[39m")
  s.gsub!(/(?<!\e)[(){}\[\]]/, "#{@colors[:paren]}\\&\e[39m")
  s.gsub!("<code>", @colors[:code])
  s << "\e[K\e[39;49m"
  # s.gsub(/[\[\](){}.,:;\^|&<>=+\-?]/, "\\0")
end

def md_whitespace(s)
  # s.gsub!(/^\s+\n/m, "\n")  # delete space on blank lines
  s.gsub!(/(\n)([ ]{4})([^\r\n]*)/m, "  \\1<code>\\3")  # check for code
  s.gsub!(/(\S)([ \t]{,1}\n[ \t]*)(\S)/m, '\1 \3')  # continue on same line if only one newline
  # s.gsub!(/^(\s*\n){2,}/m, "\n") # squeeze blank lines
  s.gsub!(/(\S)(  )\n/m, "\\1\n")  # new line if double space ending
  s.gsub!(/^[ \t]{,4}/m, '')  # remove preceding whitespace

  lmargin = ' ' * @left_margin
  s.lines.map { |line| line.prepend(lmargin) } * ''
end

def md_styleize(s)
  lines = s.lines
  lines.map do |line|
    [:bold, :italic, :bold_, :italic_, :strikeout].each do |style|
      line.gsub!(*@style_expr[style])
    end

    if (line =~ /^\s*<code>/)
      line = md_code_syntax_hl2(line, 0)
    end

    line
  end
  lines * ''
end

def md(s)
  # s.gsub!(/(\s*\n){2,}/m, "\n")
  s = md_whitespace(s)
  s = md_styleize(s)
  puts s
  # s.gsub(*@style_expr[:italic])
  #
end

md = %[
  test *italic* normal **bold** normal ***italic bold*** normal
  same paragraph on new line
  same line
  __bold underscore__
  _italic underscore_
  ~~strikeout~~

    print 'this'
    int x[3] = {1, 2, 3};
    x[0] &= 1;
    x[0] = (yep) ? (2 + 4) : (0);
    fuction(arguments, struct.member);
    printf("char: \"%c\" = %u\n", 'x', x);

  new
  paragraph
  ]

# .map {|token| @r.match(token).named_captures.compact }
# p .scan(@R).map{|i|
#   i.match(@r)
#     #
# }
