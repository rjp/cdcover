require 'rubygems'
require 'rmagick'

# graph parameters
size = 300

offset = 0.05*size
width = 0.9*size
height = 0.7*size
scale = 65536 / (height/2)
midpoint = size - 1.1*height

canvas = Magick::Image.new(size, size) { self.background_color = 'white' }
gc = Magick::Draw.new

max_vol = 65535


class Bucket
    attr_accessor :total, :count, :min, :max
    def initialize
        @total = 0
        @count = 0
        @min = 0
        @max = 0
        @pos_total = 0
        @neg_total = 0
    end
    def add(x)
        @total = @total + x
        if x > 0 then
            @pos_total = @pos_total + x
        else
            @neg_total = @neg_total + x
        end
        @count = @count + 1
        if x > @max then @max = x; end
        if x < @min then @min = x; end
    end
    def avg
        if @count > 0 then
            return @pos_total / @count, @neg_total / @count
        else
            return 0, 0
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
#test = bytes[0..441000]
#bytes = test
puts "#{bucket_size} samples in each bucket"
bytes.each_with_index { |i,j|
    left = i >> 16
    right = i & 0xFFFF
    bucket = j / bucket_size
    if j % 44100 == 0 then puts "#{j/44100} b=#{bucket}"; end
    buckets[bucket].add(left)
}
buckets.each_with_index { |b, i|
    # 261 -43.1272888183594 44.6958160400391 0.0112152099609375 / -26918 7 27897 70724 529807
    gc.stroke('#000000')
    if b.count > 0 then
        avg_p, avg_n = b.avg
        # 5 -6.80763244628906 8.06854248046875 -0.825119018554687 0.821914672851562 / -4249 -515 513 5036 70724 -88632
        puts "#{i} #{b.min/scale} #{b.max/scale} #{avg_n/scale} #{avg_p/scale} / #{b.min} #{avg_n} #{avg_p} #{b.max} #{b.count} #{b.total}"
        low = b.min # (avg_n + b.min) / 2
        high = b.max # (avg_p + b.max) / 2
        gc.line(i+offset, midpoint+low/scale, i+offset, midpoint+high/scale)
    end
}
gc.draw(canvas)
canvas.write("png/test.png")
