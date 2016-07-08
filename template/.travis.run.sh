#!/bin/bash
export ROS_DISTRO="kinetic"
export ROS_REPOSITORY_PATH=http://packages.ros.org/ros-shadow-fixed/ubuntu
export UPSTREAM_WORKSPACE=.travis.rosinstall

rm -rf .ci_config
git clone https://github.com/davetcoleman/moveit_ci.git .ci_config
source .ci_config/travis.sh || echo "run.sh Failed"
