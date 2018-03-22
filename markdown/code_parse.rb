require './escape'
require './string'
include EscSequence

@simple_tokenize_exp =/ \b[~$_a-zA-Z]\w*\b | \b\d+\.\d*[fFdD]?\b|\b\d+\b|\B0[xX]|\#?\h+\b
     |\w+|[[:punct:]]|\s+|\W+ /x

@tokenize_exp = %r[
  ('[^']*')
  |("(\"|[^"])*")
  |(<\w+>)
  |(\s+|[\r\n]+)
  |(\b\d+(\.\d+[fFdD]?)\b)
  |(\b\d+\b)
  |(\B(0[xX]|\#)?\h+\b)
  |(\b[~$_a-zA-Z]\w*\b)
  |(\w+)
  |(\p{Ps})
  |(\p{Pe})
  |([=!<>]=|[<>])
  |([+\-*\^|&%]?=)
  |([&|!\^~]{1,2})
  |([[:punct:]])
  |(\W+)
]x

@scanner_exp = %r[
    (?<string>
      ('[^']*')
      |("(\"|[^"])*"))
    |(?<tag><\w+>)
    |(?<number>
       (?<float>\b\d+(\.\d+[fFdD]?)\b)
      |(?<int>\b\d+\b)
      |(?<hex>\B(0[xX]|\#)?\h+\b))
    |(?<symbol>
      \b[~$_a-zA-Z]\w*\b)
    |(?<word>
    \w+)
    |(?<punc>
      (?<paren>
        (?<open>\p{Ps})
        |(?<close>\p{Pe}))
      |(?<comparison>[<>]|[=!<>]=+)
      |(?<assignment>[+\-*\^|&%]?=)
      |(?<bool>[&|!\^~]{1,2})
      |(?<punc_misc>[[:punct:]]))
    |(?<space>
      (?<nl>[\n\r]+)
      |([[:blank:]]+))
    |(?<other>\W+)
    ]x

# s = 'int x[3] = {1, 2, 3};'
s = %q[printf("char: \"%c\" = %u\n", 'x', x);]

def tokenize(s)
  s.scan(@tokenize_exp).map { |i| i.compact }.flatten
end

def classify_a(a)
  a.map { |s|
    m = @scanner_exp.match(s).named_captures.compact.keys
  }
end

# puts s
# puts
# tok = tokenize(s)
# puts tok*"\n"
# puts
# p classify_a(tok)

@colors = {
  code: color(:truecolor, 0xF8F8F2, 0x1D1F21),
  operator: color(:truecolor_fg, 0x92C5F7),
  paren: color(:truecolor_fg, 0x888888),
  default: "\e[39;49m"
}

@syntax_hl = {
  fg:         0xF8F8F2,
  bg:         0x1D1F21,
  string:     0xA8FF60,
  number:     0xF8F8F2,
  tag:        0x92C5F7,
  float:      0x99CC99,
  int:        0x99CC99,
  hex:        0x99CC99,
  symbol:     0xF8F8F2,
  word:       0xF8F8F2,
  punc:       0xF8F8F2,
  paren:      0x888888,
  comparison: 0xFFEE11,
  assignment: 0x92C5F7,
  bool:       0x92C5F7,
  punc_misc:  0x8F8F8F,
  space:      0xF8F8F2,
  other:      0xF8F8F2
}
@syntax_hl[:default] = @syntax_hl[:fg]

def classify(s)
  keys = @scanner_exp.match(s).named_captures.compact.keys.map(&:to_sym)
  keys.keep_if { |i| @syntax_hl.has_key?(i)}
  keys.empty? ? @syntaxhl[:fg] : keys.last
end

def get_hl_color(fg, bg = nil)
  return @syntax_hl[:fg] + @syntax_hl[:bg] unless @syntax_hl.has_key?(fg)
  s = color(:truecolor_fg, @syntax_hl[fg])
  s << color(:truecolor_bg, @syntax_hl[bg]) if bg
  s
end

def string_hl_color(s)
  get_hl_color(classify(s))
end

def md_code_syntax_hl2(s, backtick = nil)
  s.gsub!("<code>", '')
  s.gsub!(/^ {4}/, '')
  tok = tokenize(s)
  # p tok.map{|i| classify(i)}
  hl = tok.map { |i| string_hl_color(i) + i} * ''
  hl.prepend(get_hl_color(:fg, :bg))
  backtick || hl.concat("\e[K")
  hl.concat("\e[39;49m")
  # puts hl
  s.replace(hl)
  # tok.each { |i| puts string_hl_color(i) + i}

  # s.gsub!(/[,.;:\^|&=]+/, "#{@colors[:operator]}\\&\e[39m")
  # s.gsub!(/(?<!\e)[(){}\[\]]/, "#{@colors[:paren]}\\&\e[39m")
  # s.gsub!("<code>", get_hl_color(:fg, :bg))
  # s << "\e[K\e[39;49m"
end

def md_code_syntax_hl(s)
  # s.gsub!(/[\[\](){}\.,:;\^|&<>=+\-?]+/, "\e[32m\\0\e[39m")
  # s.gsub!(/(?<!\e)[(){}\[\]]/, "#{@colors[:paren]}\\&\e[39m")
  s.gsub!(/[,.;:\^|&=]+/, "#{@colors[:operator]}\\&\e[39m")
  s.gsub!(/(?<!\e)[(){}\[\]]/, "#{@colors[:paren]}\\&\e[39m")
  s.gsub!("<code>", @colors[:code])
  s << "\e[K\e[39;49m"
  # s.gsub(/[\[\](){}.,:;\^|&<>=+\-?]/, "\\0")
end
