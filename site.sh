#!/bin/sh

task_provision="provision"
task_deploy="deploy"

target_vagrant="vagrant"
target_staging="staging"
target_production="production"

full=false

address_vagrant="192.168.33.10"
address_staging=${address_vagrant}
address_production="www.sinuousrill.com"

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

if [ $target != $target_vagrant ] && [ $target != $target_staging ] && [ $target != $target_production ]; then

    echo "Error: invalid target"
    exit
fi

if [ $target == $target_vagrant ]; then
    address=$address_vagrant
elif [ $target == $target_staging ]; then
    address=$address_staging
elif [ $target == $target_production ]; then
    address=$address_production
fi

#Tasks

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