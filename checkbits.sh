# check for sox
sox -h > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
    echo "sox not found in the path"
    exit 1
fi

# check for rmagick without rubygems
ruby -rRMagick -e 1 >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "RMagick not found, trying with rubygems"
    # check for rmagick with rubygems
    ruby -rrubygems -e "require 'RMagick'" >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "RMagick not found with rubygems"
        exit 2
    fi
fi

# check for id3info
id3info /dev/null >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "id3info not found"
    exit 3
fi

echo "your kit looks complete.  sox is configured to read:"
sox -h | sed -ne 's/^AUDIO FILE FORMATS: //p'
