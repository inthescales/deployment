#!/bin/sh

user="root"

buddy_repo="repositories/bots/bot-buddy/"

# Prepare arguments

while getopts ":u:t:d:b:" opt; do
  case $opt in
    u) user=$OPTARG
    ;;
    t) target=$OPTARG
    ;;
    d) dest=$OPTARG
    ;;
    b) bot=$OPTARG
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z ${target} ]; then
    echo "Error: no target"
    exit
fi

if [ -z ${bot} ]; then
    echo "Error: no bot specified"
    exit
fi

if [ ! -d $bot_repo ]; then
    echo "Error: must set up bot directory"
    exit
fi

if [ ! -d $buddy_repo ]; then
    echo "Error: must set up bot-buddy directory"
    exit
fi

default_destination="/var/www/bots/$bot"

if [ -z $dest ]; then
    dest=$default_destination
fi

bot_repo="repositories/bots/$bot"

# Get address

address=$(sh scripts/helpers/host-address.sh $target)

# Update bot buddy

cd $buddy_repo
git pull origin master
cd ../../..

# Update bot repository

cd $bot_repo
git pull origin master
cd ../../..

# Run setup if necessary

cd $bot_repo
if [ -s scripts/setup.sh ]; then
    sh scripts/setup.sh
fi
cd ../../..

# Stop previous instance

ssh -o "StrictHostKeyChecking no" "$user@$address" "cd $dest; sh scripts/shutdown.sh"
echo "Deactivated running bot"

# Prepare remote for copy

ssh -o "StrictHostKeyChecking no" "$user@$address" "sudo rm -rf $dest; sudo mkdir -p $dest; sudo chown deploy:deploy $dest"

# Copy files to destination

scp -r -o 'StrictHostKeyChecking no' $(sh $bot_repo/scripts/files.sh $bot_repo) "${user}@${address}:${dest}"
scp -r -o 'StrictHostKeyChecking no' $buddy_repo/botbuddy.py "${user}@${address}:${dest}"
scp -r -o 'StrictHostKeyChecking no' credentials/bots/$bot/creds.json "${user}@${address}:${dest}"

echo "Deployed bot $bot"

exit