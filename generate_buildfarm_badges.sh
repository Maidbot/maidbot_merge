export moveit_packages=(
    moveit_core
    moveit_ros
    moveit_ros_benchmarks
    moveit_ros_benchmarks_gui
    moveit_ros_manipulation
    moveit_ros_move_group
    moveit_ros_perception
    moveit_ros_planning
    moveit_ros_planning_interface
    moveit_ros_robot_interaction
    moveit_ros_visualization
    moveit_ros_warehouse
    moveit_planners
    moveit_planners_ompl
    moveit_setup_assistant
    moveit_plugins
    moveit_ikfast
    moveit_commander
)
NUM_PACKAGES=${#moveit_packages[@]}

echo "## ROS Buildfarm"
echo "Note: Kinetic is not released yet"
echo ""
echo "MoveIt! Package | Indigo Source | Indigo Debian | Jade Source | Jade Debian | Kinetic Source | Kinetic Debian";
echo "------- | ------------------- | ------------------- | ------------------- | ------------------- | ------------------- | -------------------";

for ((i=0;i<NUM_PACKAGES;i++)); do
    PACKAGE_NAME=${moveit_packages[$i]}

    echo -ne "$PACKAGE_NAME | "
    # Indigo
    echo -ne "[![Build Status](http://build.ros.org/buildStatus/icon?job=Isrc_uT__${PACKAGE_NAME}__ubuntu_trusty__source)](http://build.ros.org/view/Isrc_uT/job/Isrc_uT__${PACKAGE_NAME}__ubuntu_trusty__source/) | ";
    echo -ne "[![Build Status](http://build.ros.org/buildStatus/icon?job=Ibin_uT64__${PACKAGE_NAME}__ubuntu_trusty_amd64__binary)](http://build.ros.org/view/Ibin_uT64/job/Ibin_uT64__${PACKAGE_NAME}__ubuntu_trusty_amd64__binary/) | ";

    # Jade
    echo -ne "[![Build Status](http://build.ros.org/buildStatus/icon?job=Jsrc_uT__${PACKAGE_NAME}__ubuntu_trusty__source)](http://build.ros.org/view/Jsrc_uT/job/Jsrc_uT__${PACKAGE_NAME}__ubuntu_trusty__source/) | ";
    echo -ne "[![Build Status](http://build.ros.org/buildStatus/icon?job=Jbin_uT64__${PACKAGE_NAME}__ubuntu_trusty_amd64__binary)](http://build.ros.org/view/Jbin_uT64/job/Jbin_uT64__${PACKAGE_NAME}__ubuntu_trusty_amd64__binary/) | ";

    # Kinetic
    echo -ne "[![Build Status](http://build.ros.org/buildStatus/icon?job=Ksrc_uT__${PACKAGE_NAME}__ubuntu_xenial__source)](http://build.ros.org/view/Ksrc_uT/job/Ksrc_uT__${PACKAGE_NAME}__ubuntu_xenial__source/) | ";
    echo -ne "[![Build Status](http://build.ros.org/buildStatus/icon?job=Kbin_uT64__${PACKAGE_NAME}__ubuntu_xenial_amd64__binary)](http://build.ros.org/view/Kbin_uT64/job/Kbin_uT64__${PACKAGE_NAME}__ubuntu_xenial_amd64__binary/) | ";

    # New line
    echo "";
done
