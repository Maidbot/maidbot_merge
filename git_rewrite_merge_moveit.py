#!/usr/bin/env python

from __future__ import print_function

from collections import OrderedDict
import os
import shutil
import sys
import subprocess
import time

repos_to_merge = OrderedDict([
    ('moveit_commander', 'http://github.com/ros-planning/moveit_commander.git'),
    # ('moveit_core', 'http://github.com/ros-planning/moveit_core.git'),
    # ('moveit_ros', 'http://github.com/ros-planning/moveit_ros.git'),
    # ('moveit_planners', 'http://github.com/ros-planning/moveit_planners.git'),
    # ('moveit_ikfast', 'http://github.com/ros-planning/moveit_ikfast.git'),
    # ('moveit_plugins', 'http://github.com/ros-planning/moveit_plugins.git'),
    # ('moveit_setup_assistant', 'http://github.com/ros-planning/moveit_setup_assistant.git'),
    ('moveit_experimental', None),  # Set later when the repository is setup with branches.
])

branches_to_merge = OrderedDict([
    ('indigo-devel', 'indigo'),
    ('jade-devel', 'jade'),
    ('kinetic-devel', 'kinetic'),
])

repo_dst = 'moveit'

this_dir = os.path.dirname(os.path.abspath(__file__))
template_dir = os.path.join(this_dir, 'template')


def call(cmd, *args, **kwargs):
    print("++ {0}".format(' '.join([c if ' ' not in c else "'{0}'".format(c) for c in cmd])))
    subprocess.check_call(cmd, *args, **kwargs)


def copy_file(src, dst):
    print("++ Copying '{0}'".format(os.path.relpath(src)))
    shutil.copy(src, dst)


def template_file(src, dst, subs):
    print("++ Templating '{0}'".format(os.path.relpath(src)))
    with open(src, 'r') as f:
        data = f.read()
    for k, v in subs.items():
        data = data.replace(k, v)
    with open(dst, 'w+') as f:
        f.write(data)


def main(sysargv=None):
    moveit_experimental_dir = 'moveit_experimental'
    if os.path.exists(moveit_experimental_dir):
        print("Warning! '{0}' exists, it will be removed in 5 seconds..."
              .format(moveit_experimental_dir), file=sys.stderr)
        time.sleep(5)
        shutil.rmtree(moveit_experimental_dir)

    call(['git', 'clone', 'http://github.com/ros-planning/moveit_experimental.git', moveit_experimental_dir])
    os.chdir(moveit_experimental_dir)
    for branch in branches_to_merge:
        call(['git', 'checkout', '-b', branch])
    os.chdir('..')
    repos_to_merge['moveit_experimental'] = 'file://{0}'.format(os.path.abspath(moveit_experimental_dir))

    if os.path.exists(repo_dst):
        print("Warning! '{0}' exists, it will be removed in 5 seconds..."
              .format(repo_dst), file=sys.stderr)
        time.sleep(5)
        shutil.rmtree(repo_dst)

    print("\n==> Creating git repository '{0}' to merge repositories into."
          .format(repo_dst))
    os.makedirs(repo_dst)
    os.chdir(repo_dst)
    call(['git', 'init', '.'])
    call(['git', 'commit', '-m', 'initial commit before merging branches', '--allow-empty'])

    # For each branch to be merged, setup a local branch to merge into.
    for branch, distro in branches_to_merge.items():
        print("\n==> Preparing branch '{0}'".format(branch))
        call(['git', 'checkout', '-b', branch, 'master'])

        print("\n==> Merging imported branches for branch '{0}'".format(branch))
        for repo, addr in repos_to_merge.items():
            print("==> Processing '{0}' branch from the '{1}' repository".format(branch, repo))
            temp_branch = 'temp' + '/' + repo + '/' + branch
            call(['git', 'checkout', '-b', temp_branch, branch])
            call(['git', 'pull', addr, branch, '--allow-unrelated-histories', '--no-edit'])
            call(['git', 'filter-branch', '-f',
                  '--tree-filter',
                  'mkdir -p {0}; test "$(ls -A | grep -v {0})" && mv $(ls -A | grep -v {0}) {0} || true'
                  .format(repo), 'HEAD'])
            print("==> Merging '{0}' branch from the '{1}' repository".format(branch, repo))
            call(['git', 'checkout', branch])
            call(['git', 'merge', temp_branch, '--allow-unrelated-histories', '--no-edit'])
            call(['git', 'branch', '-d', temp_branch])
            trashed_files = False
            if os.path.isfile(os.path.join(repo, '.gitignore')):
                trashed_files = True
                call(['git', 'rm', os.path.join(repo, '.gitignore')])
            if os.path.isfile(os.path.join(repo, '.travis.yml')):
                trashed_files = True
                call(['git', 'rm', os.path.join(repo, '.travis.yml')])
            if trashed_files:
                call(['git', 'commit', '-m', 'removing vestigial files after merging'])

        print("\n==> Adding new README.md and .gitignore for branch '{0}'".format(branch))
        template_file(
            os.path.join(template_dir, 'README.md.template'),
            os.path.join('README.md'),
            {
                '__DISTRO__': distro,
                '__DISTRO_CAPS__': distro.capitalize(),
            }
        )
        copy_file(os.path.join(template_dir, '.gitignore'), '.')
        if os.path.isdir(os.path.join(template_dir, distro)):
            for file in os.listdir(os.path.join(template_dir, distro)):
                if not os.path.isfile(file):
                    print("Warning! skipping non-file '{0}'".format(file),
                          file=sys.stderr)
                    continue
                copy_file(os.path.join(template_dir, distro, file), '.')
        call(['git', 'add', '.'])
        call(['git', 'commit', '-m', 'initial commit before merging repositories'])

    print("Repository complete.")
    print("Add a remote and push the branches like this:")
    print("")
    print("cd {0}".format(repo_dst))
    print("git remote add origin https://github.com/example/repo.git")
    for branch in branches_to_merge:
        print("git checkout {0}".format(branch))
        print("git push -uf origin {0}".format(branch))


if __name__ == '__main__':
    sys.exit(main())
