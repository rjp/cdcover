# graph parameters
width = 300
midpoint = 200

max_vol = 65535


class Bucket
    attr_accessor :total, :count, :min, :max
    def initialize
        @total = 0
        @count = 0
        @min = 0
        @max = 0
    end
    def add(x)
        @total = @total + x
        @count = @count + 1
        if x > @max then @max = x; end
        if x < @min then @min = x; end
    end
    def avg
        if @count > 0 then
           @total / @count
        else
            0
        end
    end
end

buckets = Array(300)

# read a 16 bit linear raw PCM file
file = ARGV[0]
x = IO.read(file)
bytes = x.unpack("i*")
test = bytes[-100..-1]
p bytes.size
bucket_size = bytes.size / width
puts "#{bucket_size} samples in each bucket"
test.each_with_index { |i,j|
    left = i >> 16
    right = i & 0xFFFF
    puts "#{j} #{left} #{right}"
}
