mkdir -p png
x=1
for i in "$@"; do
    j=${i##*-}
    k=${j%.*}
# magically convert the input file to 16 bit linear PCM
# also magically extract track information to set the title ($k)
    ruby cdcover.rb "$i" "$x" "$k"
    png=$(printf "%02d %s.png" $x "$k")
    mv png/test.png png/"$png"
    x=$((x+1))
done
