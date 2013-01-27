# cdcover

Make nice CD covers from the audio waveforms of the tracks.

## Inspiration

Wholly inspired by [Joshua Distler](http://www.joshuadistler.com/index.php?rp=0&p=97&f&i..).

## Requirements

* [sox](http://sox.sourceforge.net/)
* [RMagick](http://rmagick.rubyforge.org/)
* [mp3info](http://ibiblio.org/mp3info/)

`checkbits.sh` will report if any of these are missing.

## Limitations

* mp3info is, by design, restricted to reading tags from MP3 files
* process.sh currently only works correctly with the GNU getopt tool

## Example output

!["Post", by Bjork](http://rjp.pi.st/tmp/20090317/bjork.jpg)
