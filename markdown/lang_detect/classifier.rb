require 'yaml'

class Classifier
  @@opts = {words_only: true}
  
  def initialize(*v)
    v[0] && v[0].each_pair{|k,v|  @@opts[k] = v if @@opts.has_key?(k) }
    p @@opts
    @words = {}
    @data = {}
    @totals = Hash.new(1)
  end

  def words(code)
    partitioner = /^[_a-zA-Z][a-zA-Z0-9_\.]*$/
    splitter = /\s|(?<=[(){}\[\]]'")|(?=[(){}\[\]]'")/
    # code.split(/[^a-z]/).reject{|w| w.empty?}
    # code.split(/\s|(\b\d+)/).reject{|w| w.empty?}
    a = code.split(splitter).reject { |w| w.empty?}.partition { |v| partitioner =~ v }
    # a[1].reject! {|v| v =~ /\d/}
    # [:words, :nonwords].zip(a).to_h
    # 
    @@opts[:words_only] ? a[0] : a.flatten
  end

  def train(code,lang)
    @totals[lang] += 1
    @data[lang] ||= Hash.new(1)
    words(code).each {|w| @data[lang][w] += 1 }
    # words_nonwords = words(code)
    # words_nonwords[:nonwords].each {|w| @data[lang][w] += 1 }
    # words_nonwords[:words].each {|w| @data[lang][:words][w] += 1 }
    # words_nonwords[:nonwords].each {|w| @data[lang][:nonwords][w] += 1 }
  end

  def median(a)
    a.sort[(a.length / 2)]
  end

  def normalize
    @data.transform_values do |lang|
      scale = 1.0 / median(lang.values)
      lang.transform_values! { |x| x * scale }
    end
  end

  def classify(code)
    ws = words(code)
    @data.keys.max_by do |lang|
      Math.log(@totals[lang]) +
        ws.map { |w| Math.log(@data[lang][w].to_f) }.reduce(:+)
    end
  end

  def save
    IO.write('classify.data', @data.to_yaml)
  end
end

# Example usage

c = Classifier.new(words_only: false)

# c.words(open("code.rb").read)
# a = c.words(open("tmp.rb").read)
# p a

# Train from files
c.train(open("code.rb").read, :ruby)
c.train(open("code.py").read, :python)
c.train(open("code.c").read, :c)

c.normalize

puts c.classify(open("/home/jason/Documents/md/term/string.rb").read)
puts c.classify(open("/home/jason/Documents/md/term/escape.rb").read)
puts c.classify(open("/home/jason/Documents/c/levenshtein/test.c").read)
puts c.classify(open("/home/jason/Documents/c/levenshtein/levenshtein.c").read)
puts c.classify(open("/home/jason/Documents/python/eipi.py").read)
puts c.classify(open("/home/jason/Documents/python/mcmuggio/mcmuggio2.py").read)

# h = Hash.new(1)
# p h[:that]
# c.save
