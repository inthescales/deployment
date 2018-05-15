#!/bin/sh

user="root"
default_destination="/var/www/html/site/"

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

# Update from repository

cd repositories/Sinuous-Rill-Site/
git pull origin master
cd ../..

# Build static site

cd repositories/Sinuous-Rill-Site/
ruby sitegen.rb
cd ../..

# Prepare remote for copy

ssh -o "StrictHostKeyChecking no" "$user@$address" "rm -rf $dest; sudo mkdir -p $dest; sudo chown deploy:deploy $dest"

# Copy files to destination

scp -r -o 'StrictHostKeyChecking no' repositories/Sinuous-Rill-Site/output/* "${user}@${address}:${dest}"

exit