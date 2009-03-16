require 'rubygems'
require 'RMagick'

# graph parameters
size = 600

offset = 0.05*size
width = (0.9*size+0.5).to_i
height = 0.25*size
scale = 32768 / height
midpoint = 1.2*height

puts "size=#{size} offset=#{offset} width=#{width} height=#{height} scale=#{scale} midpoint=#{midpoint}"

canvas = Magick::Image.new(size, size) { self.background_color = 'white' }
gc = Magick::Draw.new

max_vol = 65535

file = ARGV[0]
tracknum = ARGV[1]
trackname = ARGV[2]

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

buckets = Array.new(width) { Bucket.new }

# read a 16 bit linear raw PCM file
puts "reading file ", Time.now

x=nil
# we have to fork/exec to get a clean commandline
IO.popen('-') { |p|
    if p.nil? then
        # raw 16 bit linear PCM one channel
        exec 'sox', file, '-t', 'raw', '-r', '4000', '-c', '1', '-s', '-'
    end
    x = p.read
}

puts "unpacking file ", Time.now
bytes = x.unpack("s*")

puts "bucketing samples, ", Time.now
bucket_size = (((bytes.size-1).to_f / width)+0.5).to_i + 1
p bytes.size
#test = bytes[0..441000]
#bytes = test
puts "#{bucket_size} samples in each of #{width} buckets"
bytes.each_with_index { |i,j|
#    left = i >> 16
#    right = i & 0xFFFF
    right = i
    bucket = j / bucket_size
    buckets[bucket].add(right)
}
p buckets[0..8]
puts "plotting graph ", Time.now
buckets.each_with_index { |b, i|
    gc.stroke('#000000')
    if b.count > 0 then
        avg_p, avg_n = b.avg
        # 5 -6.80763244628906 8.06854248046875 -0.825119018554687 0.821914672851562 / -4249 -515 513 5036 70724 -88632
        low = (avg_n + b.min) / 2
        high = (avg_p + b.max) / 2
        low = b.min
        high = b.max
#        puts "#{i} #{low/scale}-#{high/scale} / #{b.min/scale} #{b.max/scale} #{avg_n/scale} #{avg_p/scale} / #{b.min} #{avg_n} #{avg_p} #{b.max} #{b.count} #{b.total} #{low}-#{high}"
        gc.line(i+offset, midpoint+low/scale, i+offset, midpoint+high/scale)
    end
}
# now plot some suitably sized text
gc.pointsize = 16
gc.stroke('#888888')
gc.fill('#888888')
gc.text(0.1*size, midpoint + 1.5*height, tracknum)
gc.text(0.1*size, midpoint + 1.8*height, trackname)
gc.draw(canvas)
canvas.write("png/test.png")
puts Time.now
