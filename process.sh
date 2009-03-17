mkdir -p png
x=1

max_samples=0
for i in "$@"; do
    samples=$(soxi -s "$i")
    echo "$i = $samples"
    if [ $samples -gt $max_samples ]; then
        max_samples=$samples
    fi
done

for i in "$@"; do
    j=$(basename "$i")
    k="${j%.*}"

    samples=$(soxi -s "$i")

    # magically extract track information to set the title

### THIS IS HORRIBLE
    eval $(id3info "$i" | egrep 'TRCK|TIT2' | sed -e 's/^=== //' -e 's/"/\\"/g' -e 's/ ([^)]*): /="/' -e 's/$/"/')  
    t=${TRCK:-$x}
    trk=${t%/*}
    ttl="${TIT2:-$k}"
### THIS IS HORRIBLE

    png=$(printf "%s.png" "$k")
    ruby cdcover.rb "$i" "$trk" "$ttl" "png/$png" $max_samples $samples

    x=$((x+1))
done
