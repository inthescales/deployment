#!/bin/sh

user="root"
default_destination="/var/www/html/site/"

mkdir temp

# Prepare arguments

while getopts ":u:t:d:" opt; do
  case $opt in
    u) user=$OPTARG
    ;;
    t) target=$OPTARG
    ;;
    d) dest=$OPTARG
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z ${target} ]; then
    echo "Error: no target"
    exit
fi

if [ -z $dest ]; then
    dest=$default_destination
fi

# Get address

address=$(sh scripts/helpers/host-address.sh $target)

# Update the main site

# Update from repository

cd repositories/inthescales-site/
git pull origin master
cd ../..

# Build static site

cd repositories/inthescales-site/
ruby generate.rb
cd ../..

cp -r repositories/inthescales-site/output/ temp/site

# Update pages

cd repositories/pages
git pull origin master
cd ../..

rsync -r --exclude=".*" repositories/pages temp/site

# Update files

cd repositories/files
git pull origin master
cd ../..

rsync -r --exclude-from ".gitignore" repositories/files temp/site

# Update subsites

sh scripts/subsites-build.sh
sh scripts/subsites-copy.sh -t temp/site

# Copy files to destination

rsync -azP --delete temp/site/ "${user}@${address}:${dest}" --exclude=".git"

# Cleanup

rm -rf temp

exit
