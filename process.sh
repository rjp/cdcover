mkdir -p png
x=1
for i in "$@"; do
    j=$(basename "$i")
    k="${j%.*}"

    # magically extract track information to set the title

### THIS IS HORRIBLE
    eval $(id3info "$i" | egrep 'TRCK|TIT2' | sed -e 's/^=== //' -e 's/"/\\"/g' -e 's/ ([^)]*): /="/' -e 's/$/"/')  
    t=${TRCK:-$x}
    trk=${t%/*}
    ttl="${TIT2:-$k}"
### THIS IS HORRIBLE

    png=$(printf "%s.png" "$k")
    ruby cdcover.rb "$i" "$trk" "$ttl" "png/$png"

    x=$((x+1))
done
