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

    ruby cdcover.rb "$i" "$trk" "$ttl"

    png=$(printf "%s.png" "$k")
    mv png/test.png png/"$png"
    x=$((x+1))
done
