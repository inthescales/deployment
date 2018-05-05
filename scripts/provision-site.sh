#!/bin/sh

target=$1

k_staging="staging"
k_production="production"
k_vagrant="vagrant"

provisioning_user="root"
site_root="/var/www/html/site/"

target_vagrant="vagrant"
target_staging="staging"
target_production="production"

address_vagrant="192.168.33.10"
address_staging=${address_vagrant}
address_production="www.sinuousrill.com"

if [ $target == $target_vagrant ]; then
    address=$address_vagrant
elif [ $target == $target_staging ]; then
    address=$address_staging
elif [ $target == $target_production ]; then
    address=$address_production
fi

if [ ${target} == ${k_vagrant} ]; then
    provisioning_user="vagrant"
    vagrant up --no-provision
    vagrant provision --provision-with "site"
fi

# Set up ssh login for provisioning user

ssh-keygen -R $address
    
if [ ${target} != ${k_vagrant} ]; then

    ssh-copy-id -o "StrictHostKeyChecking no" "${provisioning_user}@${address}"
    
    # Install dependencies for and run ansible
    
    ssh -o "StrictHostKeyChecking no" "${provisioning_user}@$target" "apt-get install python"
    ansible-playbook playbooks/playbook-site.yml -i "hosts/${target}-hosts" -vvvv
fi

# Set up ssh login for deploy user

ssh-copy-id -o "StrictHostKeyChecking no" "deploy@${address}"
