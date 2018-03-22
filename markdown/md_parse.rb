# coding: utf-8
# def md_whitespace(s)
#   # s.gsub!(/^\s+\n/m, "\n")  # delete space on blank lines
#   s.gsub!(/(\n)([ ]{4})([^\r\n]*)/m, "  \\1<code>\\3")  # check for code
#   s.gsub!(/(\S)([ \t]{,1}\n[ \t]*)(\S)/m, '\1 \3')  # continue on same line if only one newline
#   s.gsub!(/(\S)(  )\n/m, "\\1\n")  # new line if double space ending
#   s.gsub!(/^[ \t]{,4}/m, '')  # remove preceding whitespace
#   lmargin = ' ' * @left_margin
#   s.lines.map { |line| line.prepend(lmargin) } * ''
# end
require 'English'
require './code_parse.rb'

module MD

  @left_margin = 2

  def squeeze_blank_lines(s)
    s.gsub!(/^(\s*\n){2,}/m, "\n")
  end

  def squeeze_space(v)
    v.replace((v =~ /^ {4,}/) ? md_code_syntax_hl2(v) : v.lstrip.squeeze(' '))
  end

  def line_break(*v) "" end

  def bullet(*v)
    v[0].gsub!(/^[+\-*]\s+/, "    \xE2\x80\xA2 ")
  end

  def ordered_list(*v)
    v[0].gsub!(/(^\d+\.)\s+/, '    \1 ')
  end

  def h_rule(*v)
    "\e7\r\e[200G" << ("\xE2\x80\x95\b\b" * 200) << "\e8\n"
  end

  def nomatch(*v) '' end

  def quote(*v)
    v[0].gsub!(/^>s+/, "  \e[48;2;12;36;48m")
  end

  def header(*v)
    part = v[0].partition(/^\#+/).reject {|x| x.empty?}
    header_style = [
      color(:truecolor, 0xFFFFFF, 0x1D1F21),
      color(:truecolor, 0xA0A0A0, 0x1D1F21),
      color(:truecolor, 0x838383, 0x1D1F21),
      color(:truecolor, 0x9696FF, 0x1D1F21),
      color(:truecolor, 0x30FF30, 0x1D1F21),
      color(:truecolor, 0xDD3232, 0x1D1F21),
      color(:truecolor, 0xFFAAAA, 0x1D1F21),
      color(:truecolor, 0x000000, 0xFFFFFF),
    ]
    v[0].replace("\e[1b" + header_style[part[0].length - 1] + part[-1] + "\e[0m")
  end

  def prefix(line)
    prefix_scanner = %r[
    (?<line_break>^\s*$)
    |(?<h_rule>^[_\-\*]{3,}\s*$)
    |(?<header>^\#+)
    |(?<bullet>(^[+\-*]\s+))
    |(?<ordered_list>^\d+\.\s+)
    |(?<code>/^ {4,}/)
    |(?<quote>/^>\s+)
    |(?<nomatch>/.*/)
    ]x

    if line
      if (m = prefix_scanner.match(line))
        name = m.named_captures.compact
        line.replace(send(name.keys[0],line))

        # puts line
      end
    end
    # [:bold, :italic, :bold_, :italic_, :strikeout].each do |style|
    # line.gsub!(*style_expr[style])
    # end
  end
  # line.partition(/)

  def styleize(line)
    style_expr = {
      italic: [/(\*{1})(([^*]+|\\\*)+)(\*{1})/, "\e[3m\\2\e[23m"],
      bold: [/(\*\*)(([^*]+|\\\*)+)(\*\*)/, "\e[1m\\2\e[21m"],
      italic_: [/(_)(([^_]+|\\\*)+)(_)/, "\e[3m\\2\e[23m"],
      bold_: [/(__)(([^_]+|\\\*)+)(__)/, "\e[1m\\2\e[21m"],
      strikeout: [/(~~)(([^*]+|\\\*)+)(~~)/, "\e[9m\\2\e[29m"],
      quote: [/(^>\s+)(.*)/, "    #{color(:truecolor, 0x999999, 0x122833)}\e[K\\2\e[39;49m"]
  # .gsub!(/^>s+/, "  \e[48;2;12;36;48m")
      # paragraph: [/^\s*\n/, "\n"],
    }

    if (line =~ / ?(`)([^`]+)(`) ?/)

      line.replace(
        styleize($PREMATCH) + md_code_syntax_hl2(" #{$2} ", true) + styleize($POSTMATCH)
      )

    end

    [:bold, :italic, :bold_, :italic_, :strikeout, :quote].each do |style|
      line.gsub!(*style_expr[style])
    end

    line
  end


  def tableize(buffer)
    table = %r[
      ^([^\|\n]*\|)+[^\n]*\n
      ^[ \t]*-{3,}:?(\s*\|\s*:?-{3,}:?)+\n
      (^([^\|\n]*\|)+[^\n]*\n)+
      ]xm

  #     8
  # 7 ┌─┬─┐ 9
  #   │ │ │
  # 4 ├─┼─┤ 6
  #   │ │ │
  # 1 └─┴─┘ 3
  #     2
    bdr = {
      '1': '└',
      '2': '┴',
      '3': '┘',
      '4': '├',
      '5': '┼',
      '6': '┤',
      '7': '┌',
      '8': '┬',
      '9': '┐',
      top: '┌┬┐', middle: '├┼┤', bottom: '└┴┘',
      v: '│', h: '─'
    }

    if table =~ buffer
      # styleize($PREMATCH) + md_code_syntax_hl2(" #{$2} ", true) + styleize($POSTMATCH)
      a = $&.split(/\n/).map { |row| row.split(/\|/).map(&:strip) }
      a.delete_at(1)
      max_width = a.transpose.map { |col| col.map(&:length).max }

      h_sep = max_width.map{ |n| bdr[:h] * (n + 2) }
      top = bdr[:'7'] + h_sep * bdr[:'8'] + "#{bdr[:'8']}\n"
      mid = bdr[:'4'] + h_sep * bdr[:'5'] + "#{bdr[:'6']}\n"
      bot = bdr[:'1'] + h_sep * bdr[:'2'] + "#{bdr[:'3']}\n"
      puts


      puts
      table = top <<
      a.map! { |row|
        # "#{@border[:h]} " +
        row = "#{bdr[:v]} " <<
              (row.map.with_index{ |col, n|
                 col.ljust(max_width[n])
               } * " #{bdr[:v]} ") <<
              " #{bdr[:v]}\n"
      }.join(mid) <<
       bot
    # a
    else
      [""]
    end
  end

  def pre_process(s)
    squeeze_blank_lines(s)
    a = s.split(/\n/).map do |line|
      if (line =~ /^ {4,}/)
        line.replace(md_code_syntax_hl2(line))
      else
        line.replace(
          styleize(line.lstrip.squeeze(' '))
        )
      end
      prefix(line)
      line
    end
    puts a*"\n"
  end
end

include MD
s = File.read('./text.md')

pre_process(s)

puts
puts tableize(s)
