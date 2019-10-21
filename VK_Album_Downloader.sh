#!/bin/bash
# VK Album Downloader. Written by: Peter Stevenson (2E0PGS).

echo "VK Album Downloader"

if [ "$1" = "" ]; then
	echo "Usage: `basename $0` <Album URL> <Options: -p preview mode>"
	exit 1
fi

# Make a directory for pictures.
dir_name=$(wget -q -O- $1 | grep '<title>' | grep -oE '>[^&]+&' | cut -d '>' -f 2 | sed 's/.$//' | sed 's/.$//')
if [ "$2" = "-p" ]; then
	dir_name=$dir_name"_preview"
fi
mkdir "$dir_name"
cd "$dir_name"

if [ "$2" = "-p" ]; then
	# Option for preview only mode
	echo "Running in Preview only mode. Downloading low res images."
	wget -nd -H -r -A jpeg,jpg --convert-links $1
	exit 1
fi

wget -q -O- $1 | grep '<a href="/photo-' | cut -d '"' -f 2 > log.txt
# Add URL to beginning of each line in the file
url="https://vk.com"
echo $url
sed -i -e "s|^|"$url"|" log.txt

# Begin second page scanning of JS for smoking gun
wget -i log.txt
ls | grep 'photo' | xargs strings | grep "z_src" | grep -oE 'z[^,]+,' | grep "http" | grep ".jpg" | cut -d '"' -f 3 | sed 's/\\//g' > log1.txt
ls | grep 'photo' | xargs rm

# Remove duplicate image links from list
awk '!a[$0]++' log1.txt > log2.txt

# Grab the pictures from the URLs from the new list we have. Track modification dates to prevent duplicate downloading of images.
wget -N -i log2.txt

# Clean up logs
rm log.txt log1.txt log2.txt

echo "Done"