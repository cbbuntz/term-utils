e1 = /===|==|!=|[<>]=?/
e2 = /\B(===|==|!=|[<>]=?)\B/

s = "= == === < > <= >= => <=> << >> >)"
t = "= == d===ddd xxxx < {x_dsf+4} > <= >= => <=> << >> >)"

# puts t.split(/\b|\s/)
puts t.split(/\s|(?<=[(){}\[\]])|(?=[(){}\[\]])|\b/)

puts s
puts

p s.scan(e1)
puts
p s.scan(e2).flatten
