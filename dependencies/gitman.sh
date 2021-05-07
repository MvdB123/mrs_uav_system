#!/bin/bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

echo "$0: installing Gitman"

distro=`lsb_release -r | awk '{ print $2 }'`

source ~/projects/mrs_repos/mrs_uav_system/venv/bin/activate
source ~/projects/mrs_repos/mrs_uav_system/venv2/bin/activate
if [ "$distro" = "18.04" ]; then
  python3 -m pip install \
  pip\
  setuptools\
  
  python -m pip install \ 
  pip\
  setuptools\
elif [ "$distro" = "20.04" ]; then
  python3 -m pip install \
  pip\
  setuptools\
fi

# Install Gitman python package 
python3 -m pip install gitman
# sudo -H pip3 install gitman