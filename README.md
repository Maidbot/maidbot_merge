# MoveIt! Merge - Migration Notes

All of the git history and the current three supported branches (indigo|jade|kinetic) have been migrated to the single repo [https://github.com/ros-planning/moveit](https://github.com/ros-planning/moveit) for the following repos:

 - https://github.com/ros-planning/moveit_core
 - https://github.com/ros-planning/moveit_ros
 - https://github.com/ros-planning/moveit_planners
 - https://github.com/ros-planning/moveit_plugins
 - https://github.com/ros-planning/moveit_setup_assistant
 - https://github.com/ros-planning/moveit_commander
 - https://github.com/ros-planning/moveit_ikfast
 - https://github.com/ros-planning/moveit_resources

As of **Friday August 5th** these repos will be fully deprecated and all code changes / PRs should be created or moved to the single *moveit* repo.

The rational for this migration is further discussed on [Discourse](http://discourse.ros.org/t/migration-to-one-github-repo-for-moveit/266).

## Merge Method

We used a common ``git merge`` method that was loosely inspired by [this blog](https://saintgimp.org/2013/01/22/merging-two-git-repositories-into-one-repository-without-losing-file-history/) to preserve the git history of all repos. The automated merge script we used can be found [here](https://github.com/davetcoleman/moveit_merge/blob/master/git_merge_moveit.sh).

## Moving Forks Over

Many MoveIt! users likely have their own forks with modifications living in their code bases - we want to encourage those users to make the migration with us to a unified repo. To make this easy for developers, we've maintained the old repo folder / package structure so that you can in theory just copy a folder over into the new git repo and do a ``commit``. Before making the copy though we recommend you ``pull`` \ ``rebase`` your old repo to the latest changes on the parent deprecated repository. This way there will the a minimum number of potential conflicts you have to sort through when syncing with the new merged ``moveit`` repo.

In the future we are interested in flattening out some of the subfolders - i.e. "moveit/moveit_ros/planning" could become "moveit/moveit_ros_planning" since this better represents the package name. But this is not part of the initial migration.

## Moving Issues Over

We would like to start opening all new issues on the new repo, and old ones should be copied there as well. This will be one of the objectives of World MoveIt! Day.

## Releasing Debians

Future releasing of indgo|jade|kinetic we be from this new unified repo.

## Large Dependency Chains

For systems that, for example, do not need visualization components we recommend disabling various packages from being built on your platform. There are several ways to do this with catkin:

### Method 1

    touch moveit/moveit_ros/visualization/CATKIN_IGNORE

etc for whatever packages you need to ignore

### Method 2

If you use catkin_tools:

    catkin config --blacklist moveit_ros_visualization

### Method 3

    rm -rf moveit/moveit_ros/visualization

And add to your .gitignore the notice to ignore the deletion.
