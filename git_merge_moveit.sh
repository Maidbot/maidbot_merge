# Assume the current directory is where we want the new repository to be created
echo ""
echo "---------------------------------------"
echo "Automated MoveIt! Repo Merging Script"
echo " by davetcoleman"
echo " inspired by: https://saintgimp.org/2013/01/22/merging-two-git-repositories-into-one-repository-without-losing-file-history/"
echo " Discussion: http://discourse.ros.org/t/migration-to-one-github-repo-for-moveit/266"
echo "---------------------------------------"
echo ""

export repo_names_to_merge=(
    moveit_core
    moveit_ros
    moveit_planners
    moveit_plugins
    moveit_setup_assistant
    moveit_commander
    moveit_ikfast
    moveit_resources
    moveit_experimental
)
export repo_ssh_to_merge=(
    http://github.com/ros-planning/moveit_core.git
    http://github.com/ros-planning/moveit_ros.git
    http://github.com/ros-planning/moveit_planners.git
    http://github.com/ros-planning/moveit_plugins.git
    http://github.com/ros-planning/moveit_setup_assistant.git
    http://github.com/ros-planning/moveit_commander.git
    http://github.com/ros-planning/moveit_ikfast.git
    http://github.com/ros-planning/moveit_resources.git
    http://github.com/ros-planning/moveit_experimental.git
)
export repo_branch_to_merge=(
    kinetic-devel #core
    kinetic-devel #ros
    kinetic-devel #planners
    jade-devel #plugins
    jade-devel #setup assistant
    jade-devel #commander
    kinetic-devel #ikfast
    master # resources
    master # experimental
)

NUM_REPOS=${#repo_names_to_merge[@]}
echo "Merging ${NUM_REPOS} repos"

set -x          # activate debugging from here

echo "Create the new repository"
git init .
git remote add origin http://github.com/davetcoleman/moveit.git

echo "Before we do a merge, we have to have an initial commit, so we’ll make a dummy commit"
git commit --allow-empty -m "Initial dummy commit"
git checkout -b kinetic-devel
git branch -d master

IGNORE_SUBFOLDERS="-I .git"

for ((i=0;i<NUM_REPOS;i++)); do
    REPO_NAME=${repo_names_to_merge[$i]}
    REPO_URL=${repo_ssh_to_merge[$i]}
    REPO_BRANCH=${repo_branch_to_merge[$i]}
    echo "---------------------------------------"
    echo "Merging in repo $i: ${REPO_NAME} from ${REPO_URL} with branch ${REPO_BRANCH}"

    # Add a remote for and fetch the old repo, then merge
    git remote add -f ${REPO_NAME} ${REPO_URL}
    git merge ${REPO_NAME}/${REPO_BRANCH} -m "Merging repo ${REPO_NAME} into main unified repo"

    # Generate a list of subfolders to ignore when moving repos into their subfolder
    IGNORE_SUBFOLDERS="$IGNORE_SUBFOLDERS -I ${REPO_NAME}"

    # Make sure there isn't already a folder within the repo named after its parent repo
    RENAMED_FOLDER=0
    if [ -d "${REPO_NAME}" ]; then
        echo "Detected existance of folder named ${REPO_NAME} inside of ${REPO_NAME} - will temporarily rename folder"
        #read -p "Press any key to continue"
        # Control will enter here if $DIRECTORY exists.
        git mv ${REPO_NAME} ${REPO_NAME}_TEMP_RENAME
        RENAMED_FOLDER=1
    fi

    # Move the repo files and folders into a subdirectory so they don’t collide with the other repo coming later
    mkdir ${REPO_NAME}
    ls -A ${IGNORE_SUBFOLDERS} | xargs -I % git mv % ${REPO_NAME}

    # Rename folder back to original name
    if [ "$RENAMED_FOLDER" -eq "1" ]; then
        git mv ${REPO_NAME}/${REPO_NAME}_TEMP_RENAME ${REPO_NAME}/${REPO_NAME}
        echo "Renamed ${REPO_NAME} inside of ${REPO_NAME} back to original name"
        #read -p "Press any key to continue"
    fi


    # Commit the move
    git commit -m "Moved ${REPO_NAME} into subdirectory"

    # Cleanup the temporary remote
    git remote remove ${REPO_NAME}
done

# Delete package's .gitignore and travis config if it exists
for ((i=0;i<NUM_REPOS;i++)); do
    REPO_NAME=${repo_names_to_merge[$i]}
    rm ${REPO_NAME}/.gitignore
    rm ${REPO_NAME}/.travis.yml
done

git commit -a -m "Deleted duplicate gitignore and travis files"

# User feedback
echo "Finished combining repos"
echo "Showing second level contents of combined repos:"
tree -L 2

# Get directory of moveit_merge
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy in README.md and .travis.yml from this repo's template folder
cp $SCRIPT_DIR/template/.* $SCRIPT_DIR/template/* .
git add -A && git commit -a -m "Added README, travis CI, and rosinstall file"

# Push to Github
#git push origin kinetic-devel -f

set +x          # stop debugging from here
