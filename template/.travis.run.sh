#!/bin/bash
export ROS_DISTRO="kinetic"
export ROS_REPOSITORY_PATH=http://packages.ros.org/ros-shadow-fixed/ubuntu
export UPSTREAM_WORKSPACE=moveit.rosinstall

rm -rf .moveit_ci
git clone https://github.com/ros-planning/moveit_ci.git .moveit_ci
source .moveit_ci/travis.sh || echo ".travis.run.sh Failed"
