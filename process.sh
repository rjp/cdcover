# TODO fold all this into the single ruby script?

# option parsing cargo-culted from /usr/share/getopt/getopt-parse.bash
TEMP=`getopt -o mo:sw: --long montage,outputdir:,scaling,window: \
     -n 'cdcover.process' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

OUTDIR="png"
NO_SCALING=1

while true ; do
	case "$1" in
        -o|--outputdir) OUTDIR=$2; shift 2;;
        -s|--scaling)   unset NO_SCALING; shift;;
        -m|--montage)   MONTAGE=1; shift;;
        -w|--window)    MV_WINDOW=$2; shift 2;;
        --) shift; break;;
        *) echo "Internal error with getopt"; exit 1;;
    esac
done

mkdir -p "$OUTDIR"
x=1

max_samples=1

if [ ! $NO_SCALING ]; then
	for i in "$@"; do
	    samples=$(soxi -s "$i")
	    echo "$i = $samples"
	    if [ $samples -gt $max_samples ]; then
	        max_samples=$samples
	    fi
	done
fi

tmpfile=$(mktemp)

for i in "$@"; do
    j=$(basename "$i")
    k="${j%.*}"

    if [ ! $NO_SCALING ]; then
        samples=$(soxi -s "$i")
    else
        samples=1
    fi

    # magically extract track information to set the title

### THIS IS HORRIBLE
    eval $(id3info "$i" | egrep 'TRCK|TIT2' | sed -e 's/^=== //' -e 's/"/\\"/g' -e 's/ ([^)]*): /="/' -e 's/$/"/')  
    t=${TRCK:-$x}
    trk=${t%/*}
    ttl="${TIT2:-$k}"
### THIS IS HORRIBLE

    png=$(printf "%s.png" "$k")
    echo ruby cdcover.rb "$i" "$trk" "$ttl" "$OUTDIR/$png" $max_samples $samples $MV_WINDOW
    ruby cdcover.rb "$i" "$trk" "$ttl" "$OUTDIR/$png" $max_samples $samples $MV_WINDOW
    echo $png >> "$tmpfile"

    x=$((x+1))
done

if [ $MONTAGE ]; then
    montage -tile 4x4 -geometry 150x150 @"$tmpfile" "$OUTDIR/montage.png"
fi

rm -f "$tmpfile"
