require 'rubygems'
require 'RMagick'

# graph parameters
size = 600

offset = 0.05*size
width = (0.9*size+0.5).to_i
height = 0.25*size
scale = 32768 / height
midpoint = 1.4*height

# puts "size=#{size} offset=#{offset} width=#{width} height=#{height} scale=#{scale} midpoint=#{midpoint}"

canvas = Magick::Image.new(size, size) { self.background_color = 'white' }
gc = Magick::Draw.new

max_vol = 65535

file = ARGV[0]
tracknum = ARGV[1]
trackname = ARGV[2]
output = ARGV[3]
max_samples = ARGV[4].to_i
samples = ARGV[5].to_i

width = width * samples / max_samples

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
# puts "reading file ", Time.now

x=nil
sox_command = [ 'sox', file, '-t', 'raw', '-r', '4000', '-c', '1', '-s', '-L', '-' ]
# we have to fork/exec to get a clean commandline
IO.popen('-') { |p|
    if p.nil? then
        # raw 16 bit linear PCM one channel
        $stderr.close
        exec *sox_command
    end
    x = p.read
}

if x.size == 0 then
    puts "sox returned no data, command was\n> #{sox_command.join(' ')}"
    exit 1
end

# puts "unpacking file ", Time.now
bytes = x.unpack("s*")

# puts "bucketing samples, ", Time.now
bucket_size = (((bytes.size-1).to_f / width)+0.5).to_i + 1
# p bytes.size
#test = bytes[0..441000]
#bytes = test
# puts "#{bucket_size} samples in each of #{width} buckets"
bytes.each_with_index { |i,j|
#    left = i >> 16
#    right = i & 0xFFFF
    right = i
    bucket = j / bucket_size
    buckets[bucket].add(right)
}

# puts "plotting graph ", Time.now
window = 5
start = (window/2).to_i

start.upto(buckets.size-(window-1)) { |i|
    t_min = 0
    t_max = 0

    (-start..start).each { |o|
        t_min = t_min + buckets[i+o].min
        t_max = t_max + buckets[i+o].max
    }

    low = t_min / window
    high = t_max / window

    gc.line(i+offset, midpoint+low/scale, i+offset, midpoint+high/scale)
}
# now plot some suitably sized text
gc.pointsize = 36
gc.stroke('#888888')
gc.fill('#888888')

metrics = gc.get_type_metrics(canvas, trackname)
# puts "width of [#{trackname}] is #{metrics.width}"
single_height = metrics.height

def linebreak(t, gc, canvas, width, depth=0)
    trackname = t
    extra = ""
    loop do
	    left, mid, right = trackname.rpartition(/[^[:alpha:].,]/)
	    metrics = gc.get_type_metrics(canvas, left)
	    if metrics.width < width then
	        trackname = left + "\n" + right + extra
	        metrics = gc.get_multiline_type_metrics(canvas, trackname)
            if metrics.width > width then
                bits = linebreak(right + extra, gc, canvas, width, depth+1)
                trackname = left + "\n" + bits
	            metrics = gc.get_multiline_type_metrics(canvas, trackname)
            end
	        break
	    else
            extra = mid + right + extra
            trackname = left
        end
    end
    return trackname
end

if metrics.width > width then # we have to break the text somewhere
    trackname = linebreak(trackname, gc, canvas, width)
end

gc.text(offset, midpoint + 1.5*height, tracknum)
gc.text(offset, midpoint + 1.5*height + 1.1*single_height, trackname)
gc.draw(canvas)
canvas.write(output)
# puts Time.now
