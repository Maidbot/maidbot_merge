# Maidbot robotics software migration notes

This repository provides a script and set of templates to easily merge multiple repositories owned by Maidbot (see list below). It is a Maidbot-configured fork the [MoveIt! merge](https://github.com/davetcoleman/moveit_merge/#merge-method) migration written by Davet Coleman.

## Repositories to be merged
All `master` and `devel` branches from specified are brought over in the merge. These repositories will continue to exist for some time to ease the transition.

## Todos

  - [ ] Validate that the unified repository is properly created and code builds/runs as expected.
  - [ ] Transfer all PRs and Issues over (possibly using [kamino](https://github.com/gatewayapps/kamino)?)
  - [ ] Create any required tags
  - [ ] Let all users know to fork this repo and stop development on their personal forks of the deprecated repos
