#!/bin/sh

task_provision="provision"
task_deploy="deploy"
task_startup="startup"
task_shutdown="shutdown"

target_vagrant="vagrant"
target_staging="staging"
target_production="production"

deploy_user="deploy"

full=false

# Prepare arguments

while getopts "fa:t:b:" opt; do
  case $opt in
    f) full=true
    ;;
    a) task=$OPTARG
    ;;
    t) target=$OPTARG
    ;;
    b) bot=$OPTARG
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z ${task} ]; then
    echo "Error: no task"
    exit
fi

if [ -z ${target} ]; then
    echo "Error: no target"
    exit
fi

if [ $target != $target_vagrant ] && [ $target != $target_staging ] && [ $target != $target_production ]; then

    echo "Error: invalid target"
    exit
fi

destination="/var/www/bots/$bot"
address=$(sh scripts/helpers/host-address.sh $target)

#Tasks

provision()
{
    sh scripts/provision-bot.sh "$target"
}

deploy()
{    
    sh scripts/deploy-bot.sh -u $deploy_user -t $address -b $bot
}

startup()
{
    ssh -o "StrictHostKeyChecking no" "$deploy_user@$address" "cd $destination; sh scripts/startup.sh;"
    echo "Activated bot"
}

shutdown()
{
    ssh -o "StrictHostKeyChecking no" "$deploy_user@$address" "cd $destination; sh scripts/shutdown.sh;"
    echo "Deactivated bot"
}

# Running

if [ $task == $task_provision ]; then
    
    provision
elif [ $task == $task_deploy ]; then
    
    if [ $full == true ]; then
        provision
    fi
    
    deploy
    
    if [ $full == true ]; then
        startup
    fi
elif [ $task == $task_startup ]; then

    startup
    
elif [ $task == $task_shutdown ]; then

    shutdown
    
fi