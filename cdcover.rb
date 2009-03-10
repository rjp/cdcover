file = ARGV[0]
x = IO.read(file)
bytes = x.unpack("i*")
test = bytes[-100..-1]
test.each_with_index { |i,j|
    left = i >> 16
    right = i & 0xFFFF
    puts "#{j} #{left} #{right}"
}
p bytes.size
