# TODO fold all this into the single ruby script?

# option parsing cargo-culted from /usr/share/getopt/getopt-parse.bash
TEMP=`getopt -o efmo:sw:x --long outline,force,montage,outputdir:,scaling,window:,spikey \
     -n 'cdcover.process' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

OUTDIR="png"
NO_SCALING=1
GRAPH_TYPE="normal"
MV_WINDOW=5

while true ; do
	case "$1" in
        -o|--outputdir) OUTDIR=$2; shift 2;;
        -s|--scaling)   unset NO_SCALING; shift;;
        -m|--montage)   MONTAGE=1; shift;;
        -w|--window)    MV_WINDOW=$2; shift 2;;
        -f|--force)     FORCE_OUT=1; shift;;
        -x|--spikey)    GRAPH_TYPE='spikey'; shift;;
        -e|--outline)   GRAPH_TYPE='outline'; shift;;
        --) shift; break;;
        *) echo "Internal error with getopt"; exit 1;;
    esac
done

mkdir -p "$OUTDIR"
x=1

max_samples=1

track_length () {
    # Samples read:          12582912
    sox "$1" -n stat 2>&1 | sed -ne 's/^Samples read: *//p'
}

if [ ! $NO_SCALING ]; then
	for i in "$@"; do
	    samples=$(track_length "$i")
# echo "$i = $samples"
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
        samples=$(track_length "$i")
    else
        samples=1
    fi

    # magically extract track information to set the title
    a=$(mp3info -p "%-8n%t" "$i")
    trk=${a:0:8}; trk="${trk:-$x}"
    ttl=${a:8}; ttl="${ttl:-$k}"

### THIS IS ALSO HORRIBLE
# force all the output filenames to have no spaces because montage is dumb
    t_png=$(printf "%s.png" "$k")
    png="${t_png// /_}"

# echo ruby cdcover.rb "$i" "$trk" "$ttl" "$OUTDIR/$png" $max_samples $samples $MV_WINDOW
    update_file=0
    if [ $FORCE_OUT ]; then update_file=1; fi
    if [ "$i" -nt "$OUTDIR/$png" ]; then update_file=1; fi

    if [ $update_file -gt 0 ]; then
        ruby cdcover.rb "$i" "$trk" "$ttl" "$OUTDIR/$png" $max_samples $samples $GRAPH_TYPE $MV_WINDOW
    fi
    echo "$OUTDIR/$png" >> "$tmpfile"

    x=$((x+1))
done

if [ $MONTAGE ]; then
    montage -tile 4x4 -geometry 150x150 @"$tmpfile" "$OUTDIR/montage.png"
fi

rm -f "$tmpfile"
