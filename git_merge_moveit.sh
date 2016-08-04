# Assume the current directory is where we want the new repository to be created
echo ""
echo "---------------------------------------"
echo "Automated MoveIt! Repo Merging Script"
echo " by davetcoleman"
echo " inspired by: https://saintgimp.org/2013/01/22/merging-two-git-repositories-into-one-repository-without-losing-file-history/"
echo " Discussion: http://discourse.ros.org/t/migration-to-one-github-repo-for-moveit/266"
echo " Requres all repos have kinetic/jade/indigo-devel branches, except *_experiemental"
echo "---------------------------------------"
echo ""

# TO RUN:
# rm -rf moveit && mkdir moveit && cd moveit && bash ../moveit_merge/git_merge_moveit.sh

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
echo "Merging ${NUM_REPOS} repos"

set -x          # activate debugging from here

echo "Create the new repository"
git init .
git remote add origin http://github.com/ros-planning/moveit.git

echo "Before we do a merge, we have to have an initial commit, so we’ll make a dummy commit"
git commit --allow-empty -m "Initial dummy commit"
git checkout -b indigo-devel-temporary-unique-name
git checkout -b jade-devel-temporary-unique-name
git checkout -b kinetic-devel-temporary-unique-name
git branch -d master

# All repos must have unique branches for I/J/K so we clone them and make unique branches
# Currently *_experiemental does not

git clone http://github.com/ros-planning/moveit_experimental.git
cd moveit_experimental
hub remote add davetcoleman
git co -b indigo-devel
git co -b jade-devel
git co -b kinetic-devel
git push davetcoleman --all -f
cd ..
rm -rf moveit_experimental

function errorFunc() {
    echo "Error occurred, aborting"
    exit 1
}

IGNORE_SUBFOLDERS="-I .git"

for ((i=0;i<NUM_REPOS;i++)); do
    REPO_NAME=${repo_names_to_merge[$i]}
    REPO_URL=${repo_ssh_to_merge[$i]}
    echo "---------------------------------------"
    echo "Merging in repo $i: ${REPO_NAME} from ${REPO_URL}"

    # Add a remote for and fetch the old repo
    git remote add -f ${REPO_NAME} ${REPO_URL} || errorFunc

    for ((j=0;j<NUM_BRANCHES;j++)); do
        if [ "$j" -eq "0" ]; then
            BRANCH_NAME=kinetic-devel
        elif [ "$j" -eq "1" ]; then
            BRANCH_NAME=jade-devel
        else
            BRANCH_NAME=indigo-devel
        fi

        git checkout ${BRANCH_NAME}-temporary-unique-name || errorFunc

        echo "Processing branch ${BRANCH_NAME}"
        #read -p "wait" var1

        # Merge the remote repo
        git merge ${REPO_NAME}/${BRANCH_NAME} -m "Merging repo ${REPO_NAME} into main unified repo" || errorFunc

        # Generate a list of subfolders to ignore when moving repos into their subfolder
        IGNORE_SUBFOLDERS="$IGNORE_SUBFOLDERS -I ${REPO_NAME}"

        # Make sure there isn't already a folder within the repo named after its parent repo
        RENAMED_FOLDER=0
        if [ -d "${REPO_NAME}" ]; then
            echo "Detected existance of folder named ${REPO_NAME} inside of ${REPO_NAME} - will temporarily rename folder"
            #read -p "Press any key to continue"
            # Control will enter here if $DIRECTORY exists.
            git mv ${REPO_NAME} ${REPO_NAME}_TEMP_RENAME || errorFunc
            RENAMED_FOLDER=1
        fi

        # Move the repo files and folders into a subdirectory so they don’t collide with the other repo coming later
        mkdir ${REPO_NAME} || errorFunc
        ls -A ${IGNORE_SUBFOLDERS} | xargs -I % git mv % ${REPO_NAME}

        # Rename folder back to original name
        if [ "$RENAMED_FOLDER" -eq "1" ]; then
            git mv ${REPO_NAME}/${REPO_NAME}_TEMP_RENAME ${REPO_NAME}/${REPO_NAME}  || errorFunc
            echo "Renamed ${REPO_NAME} inside of ${REPO_NAME} back to original name"
            #read -p "Press any key to continue"
        fi

        # Commit the move
        git commit -m "Moved ${REPO_NAME} into subdirectory"  || errorFunc
    done

    # Cleanup the temporary remote
    git remote remove ${REPO_NAME}
done

# Delete package's .gitignore and travis config if it exists
for ((i=0;i<NUM_REPOS;i++)); do
    REPO_NAME=${repo_names_to_merge[$i]}
    rm ${REPO_NAME}/.gitignore
    rm ${REPO_NAME}/.travis.yml
done

git commit -a -m "Deleted duplicate gitignore and travis files"  || errorFunc

# Rename branches to normal
git branch -m indigo-devel-temporary-unique-name indigo-devel  || errorFunc
git branch -m jade-devel-temporary-unique-name jade-devel  || errorFunc
git branch -m kinetic-devel-temporary-unique-name kinetic-devel  || errorFunc

# Get directory of moveit_merge
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy in various files for every branch

# Indigo
git co indigo-devel  || errorFunc
cp $SCRIPT_DIR/template/README.md .  || errorFunc
sed -i 's/kinetic/indigo/g' README.md  || errorFunc
cp $SCRIPT_DIR/template/indigo/.travis.yml .  || errorFunc
cp $SCRIPT_DIR/template/indigo/moveit.rosinstall .  || errorFunc
cp $SCRIPT_DIR/template/.gitignore . || errorFunc
git add -A && git commit -a -m "Added README, travis CI, and rosinstall file" || errorFunc

# Jade
git co jade-devel || errorFunc
cp $SCRIPT_DIR/template/README.md .  || errorFunc
sed -i 's/kinetic/jade/g' README.md  || errorFunc
cp $SCRIPT_DIR/template/jade/.travis.yml .  || errorFunc
cp $SCRIPT_DIR/template/jade/moveit.rosinstall .  || errorFunc
cp $SCRIPT_DIR/template/.gitignore .  || errorFunc
git add -A && git commit -a -m "Added README, travis CI, and rosinstall file" || errorFunc

# Kinetic
git co kinetic-devel || errorFunc
cp $SCRIPT_DIR/template/README.md .  || errorFunc
cp $SCRIPT_DIR/template/kinetic/.travis.yml .  || errorFunc
cp $SCRIPT_DIR/template/kinetic/.travis.before_script .  || errorFunc
cp $SCRIPT_DIR/template/kinetic/moveit.rosinstall . || errorFunc
cp $SCRIPT_DIR/template/.gitignore . || errorFunc
git add -A && git commit -a -m "Added README, travis CI, and rosinstall file" || errorFunc

set +x          # stop debugging from here

# Verify repos are the same
for ((i=0;i<NUM_REPOS;i++)); do
    REPO_NAME=${repo_names_to_merge[$i]}
    REPO_URL=${repo_ssh_to_merge[$i]}
    echo "---------------------------------------"
    echo "Verifying repo: ${REPO_NAME}"

    for ((j=0;j<NUM_BRANCHES;j++)); do
        if [ "$j" -eq "0" ]; then
            BRANCH_NAME=kinetic-devel
        elif [ "$j" -eq "1" ]; then
            BRANCH_NAME=jade-devel
        else
            BRANCH_NAME=indigo-devel
        fi

        # Switch to the correct branch to test
        git co $BRANCH_NAME || errorFunc

        # Clone the original version
        git clone ${REPO_URL} -b ${BRANCH_NAME}  ${REPO_NAME}_${BRANCH_NAME} || errorFunc
        # Do not comapare git repos
        rm -rf ${REPO_NAME}_${BRANCH_NAME}/.git

        echo "Comparing $BRANCH_NAME:"
        diff -x '.gitignore' -x '.travis.yml' -r ${REPO_NAME} ${REPO_NAME}_${BRANCH_NAME} || errorFunc

        rm -rf ${REPO_NAME}_${BRANCH_NAME}
    done
done

# User feedback
echo "Finished combining repos"
echo "Showing second level contents of combined repos:"
tree -L 2

# Push to Github
#git push origin --all -f
