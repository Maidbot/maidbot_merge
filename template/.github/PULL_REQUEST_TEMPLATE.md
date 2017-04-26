## Pull Request Summary

Briefly explain the purpose of the feature (often related to a user story),
the goal of the improvement, or the problem that your bugfix is addressing.

## Supporting References

- JIRA issue: [RSW-###](https://maidbot.atlassian.net/browse/RSW-###)
- Design document: [name](URL)
- Other reference: [name](URL)

## Dependencies

If your feature is dependent on another branch, please mention it here and link
to the corresponding pull request.

Also mention any other dependencies, such as to external libraries
or specific parametrization of a config file in some other repository.

Feel free to remove this section entirely if it doesn't apply to your PR.

## Instructions

Describe what the reviewer needs to do in order to run your code. Example:

```
roslaunch my_new_package my_amazing_launch_file.launch
```

## TODO :white_check_mark:

List any TODO items that you would like to keep track of.
These should be specific to this PR, not duplicates of JIRA subtasks.

- Preliminaries
  - [ ] Prefix the PR title with the JIRA issue number (RSW-###)
  - [ ] Fill out the body of the pull request template
  - [ ] Add the appropriate GitHub labels and assign the PR
- Before requesting formal review
  - [ ] Update any third-party code (e.g. `maidbot-devel` branches):
    - `cd ~/Maidbot/catkin_ws/src && wstool update && cd -`
  - [ ] Rebase this PR's work on top of the latest `devel` branch:
    - `git co devel && git pull --ff-only --rebase`
    - `git co YOUR_BRANCH && git rebase`
  - [ ] Add new dependencies in the appropriate locations:
    - `platform.ini` for microcontroller-level dependencies
    - `maidbot_install/requirements.txt` for python dependencies
    - `CMakeLists.txt` and `package.xml` ROS-level dependencies
    - `maidbot_install/maidbot.rosinstall` for external ROS packages
  - [ ] Check that the compiles at all levels:
    - `pio run` (especially `main`) for microcontroller environments
    - `catkin clean -y && catkin build` for the ROS workspace
  - [ ] Run tests:
    - *TBD*
  - [ ] Comply with code style:
    - `roslint` for ROS-level source code
    - `catkin_lint` for ROS-level build files (`CMakeLists.txt` and `package.xml`)
