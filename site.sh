#!/bin/sh

task_provision="provision"
task_deploy="deploy"

target_vagrant="vagrant"
target_staging="staging"
target_production="production"

full=false

# Prepare arguments

while getopts "fa:t:" opt; do
  case $opt in
    f) full=true
    ;;
    a) task=$OPTARG
    ;;
    t) target=$OPTARG
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

if [ $target != $target_vagrant ] \
    && [ $target != $target_staging ] \
    && [ $target != $target_production ]; then

    echo "Error: invalid target"
    exit
fi

address=$(sh scripts/helpers/host-address.sh $target)

# Tasks

provision()
{
    sh scripts/provision-site.sh "$target"
}

deploy()
{    
    sh scripts/deploy-site.sh -u deploy -t $address
}

# Running

if [ $task == $task_provision ]; then
    
    provision
elif [ $task == $task_deploy ]; then
    
    if [ $full == true ]; then
        provision
    fi
    
    deploy
fi
