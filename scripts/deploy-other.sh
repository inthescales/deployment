#!/bin/sh

user="root"

# Prepare arguments

while getopts ":u:t:d:r:" opt; do
  case $opt in
    u) user=$OPTARG
    ;;
    t) target=$OPTARG
    ;;
    d) dest=$OPTARG
    ;;
    r) repo=$OPTARG
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z ${target} ]; then
    echo "Error: no target"
    exit
fi

if [ -z ${repo} ]; then
    echo "Error: no bot specified"
    exit
fi

default_destination="/var/www/other/$repo"

if [ -z $dest ]; then
    dest=$default_destination
fi

repo_dir="repositories/other/$repo"

# Get address

address=$(sh scripts/helpers/host-address.sh $target)

# Update repository

cd $repo_dir
git pull origin master
cd ../../..

# Prepare remote for copy

ssh -o "StrictHostKeyChecking no" "$user@$address" "sudo rm -rf $dest; sudo mkdir -p $dest; sudo chown deploy:deploy $dest"

# Copy files to destination

scp -r -o 'StrictHostKeyChecking no' "${repo_dir}" "${user}@${address}:${dest}"

echo "Deployed $repo"

exit