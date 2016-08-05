echo ""
echo "---------------------------------------"
echo "Check that new repo has same code using diff"
echo " by davetcoleman"
echo "---------------------------------------"
echo ""
echo "Assume the current directory is the merged repo"
echo "To prevent shell from closing:"
echo "    bash ../moveit_merge/verify_merged_repos.sh"

export repo_names_to_merge=(
    moveit_core
    moveit_ros
    moveit_planners
    moveit_ikfast
    moveit_plugins
    moveit_setup_assistant
    moveit_commander
    moveit_experimental
)
export repo_ssh_to_merge=(
    http://github.com/ros-planning/moveit_core.git
    http://github.com/ros-planning/moveit_ros.git
    http://github.com/ros-planning/moveit_planners.git
    http://github.com/ros-planning/moveit_ikfast.git
    http://github.com/ros-planning/moveit_plugins.git
    http://github.com/ros-planning/moveit_setup_assistant.git
    http://github.com/ros-planning/moveit_commander.git
    http://github.com/davetcoleman/moveit_experimental.git
)

NUM_REPOS=${#repo_names_to_merge[@]}
NUM_BRANCHES=3
echo "Verifying ${NUM_REPOS} repos"

function errorFunc() {
    echo "Error occurred, aborting"
    exit 1
}

# Verify repos are the same
for ((i=0;i<NUM_REPOS;i++)); do
    REPO_NAME=${repo_names_to_merge[$i]}
    REPO_URL=${repo_ssh_to_merge[$i]}
    echo ""
    echo "--------------------------------------------------------"
    echo "Verifying repo: ${REPO_NAME}"
    echo "--------------------------------------------------------"
    echo ""

    # Clone the original version and make sure it has all the branches
    git clone ${REPO_URL} ${REPO_NAME}_verification || errorFunc
    cd ${REPO_NAME}_verification
    git co kinetic-devel || errorFunc # kinetic is the default
    git co -b indigo-devel origin/indigo-devel || errorFunc
    git co -b jade-devel origin/jade-devel || errorFunc
    cd ..

    # For each branch
    for ((j=0;j<NUM_BRANCHES;j++)); do
        if [ "$j" -eq "0" ]; then
            BRANCH_NAME=kinetic-devel
        elif [ "$j" -eq "1" ]; then
            BRANCH_NAME=jade-devel
        else
            BRANCH_NAME=indigo-devel
        fi

        # Switch repo being tested to the correct branch
        git co $BRANCH_NAME || errorFunc

        # Switch comparison repo
        cd ${REPO_NAME}_verification || errorFunc
        git co $BRANCH_NAME || errorFunc
        cd ..

        echo "---------------------------------------"
        echo "Comparing $BRANCH_NAME:"
        diff -x '.gitignore' -x '.travis.yml' -x '.git' -r ${REPO_NAME} ${REPO_NAME}_verification || errorFunc
        echo "PASSED!"
        echo ""
    done

    rm -rf ${REPO_NAME}_verification || errorFunc
done
