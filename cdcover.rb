# graph parameters
width = 280
midpoint = 200
scale = 65536 / 90

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

buckets = Array.new(300) { Bucket.new }

# read a 16 bit linear raw PCM file
file = ARGV[0]
x = IO.read(file)
bytes = x.unpack("i*")
bucket_size = bytes.size / width
p bytes.size
test = bytes[0..441000]
bytes = test
puts "#{bucket_size} samples in each bucket"
bytes.each_with_index { |i,j|
    left = i >> 16
    right = i & 0xFFFF
    bucket = j / bucket_size
    if j % 44100 == 0 then puts "#{j/44100} b=#{bucket}"; end
    buckets[bucket].add(left)
}
buckets.each_with_index { |b, i|
    puts "#{i} #{b.min/scale} #{b.max/scale}"
}
