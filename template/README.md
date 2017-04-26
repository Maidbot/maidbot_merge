# Maidbot robotics software migration notes

This repository provides a script and set of templates to easily merge multiple repositories owned by Maidbot (see list below). It is a Maidbot-customized version of the [MoveIt! merge](https://github.com/davetcoleman/moveit_merge/#merge-method) migration written by Davet Coleman.

## Repositories to be merged
All `master` and `devel` branches from the following repositoires are brought over in the merge. If either does not exist (e.g. `devel` in `maidbot_utils`), it has been created. These repositories will continue to exist for some time to ease the transition.

  - [maidbot_install](http://github.com/Maidbot/maidbot_install.git)
  - [maidbot_microcontroller](http://github.com/Maidbot/maidbot_microcontroller.git)
  - [maidbot_coverage](http://github.com/Maidbot/maidbot_coverage.git)
  - [maidbot_execution](http://github.com/Maidbot/maidbot_execution.git)
  - [maidbot_monitoring](http://github.com/Maidbot/maidbot_monitoring.git)
  - [maidbot_ros](http://github.com/Maidbot/maidbot_ros.git)
  - [maidbot_rosie](http://github.com/Maidbot/maidbot_rosie.git)
  - [maidbot_utils](http://github.com/Maidbot/maidbot_utils.git)

## Todos

  - [ ] Validate that the unified repository is properly created and code builds/runs as expected.
  - [ ] Transfer PRs and Issues over (possibly using [kamino](https://github.com/gatewayapps/kamino)?)
  - [ ] Create any required tags
  - [ ] Let all users know to fork this repo and stop development on their personal forks of the deprecated repos
