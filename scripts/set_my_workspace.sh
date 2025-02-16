#!/bin/bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

# get the path to this script
APP_PATH=`dirname "$0"`
APP_PATH=`( cd "$APP_PATH" && pwd )`

WORKSPACE_NAME=current_mrs_workspace
WORKSPACE_PATH=~/workspaces/$WORKSPACE_NAME
MRS_WORKSPACE=~/workspaces/mrs_workspace

# create the folder structure
mkdir -p $WORKSPACE_PATH/src

cd $WORKSPACE_PATH
command catkin init

echo "$0: setting up build profiles"
command catkin config --profile debug --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17 -march=native' -DCMAKE_C_FLAGS='-march=native'
command catkin profile set debug
command catkin config --extend $MRS_WORKSPACE/devel

command catkin config --profile release --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17 -march=native'  -DCMAKE_C_FLAGS='-march=native'
command catkin profile set release
command catkin config --extend $MRS_WORKSPACE/devel

command catkin config --profile reldeb --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17 -march=native' -DCMAKE_C_FLAGS='-march=native'
command catkin profile set reldeb
command catkin config --extend $MRS_WORKSPACE/devel

# normal installation
[ -z "$GITHUB_CI" ] && command catkin profile set reldeb

# TRAVIS CI build
# set debug for faster build
[ ! -z "$GITHUB_CI" ] && command catkin profile set debug

echo "$0: cloning example packages"
cd ~/projects/mrs_repos
[ ! -e example_ros_packages ] && git clone https://github.com/MvdB123/example_ros_packages.git
cd example_ros_packages
gitman install

echo "$0: linking example packages to ~/workspace"
cd $WORKSPACE_PATH/src
ln -sf ~/projects/mrs_repos/example_ros_packages

echo "$0: building $WORKSPACE_PATH"
cd $WORKSPACE_PATH
[ -z "$GITHUB_CI" ] && command catkin build
[ ! -z "$GITHUB_CI" ] && command catkin build --limit-status-rate 0.2 --summarize

num=`cat ~/.bashrc_mrs | grep "$WORKSPACE_PATH" | wc -l`
if [ "$num" -lt "1" ]; then

  # set bashrc
  echo "
source $WORKSPACE_PATH/devel/setup.bash" >> ~/.bashrc_mrs

fi
