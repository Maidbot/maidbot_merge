#!/usr/bin/env python

from __future__ import print_function

from distutils.version import LooseVersion
from collections import OrderedDict
import os
import shutil
import sys
import subprocess
import time
import yaml

# Set git version for compatibility
git_version = subprocess.check_output(['git', '--version']).split()[-1].strip()
git_pre_274 = LooseVersion(git_version) < LooseVersion("2.7.4")


with open("repos.yaml", 'r') as yaml_file:
    repos = yaml.load(yaml_file)
repos_to_merge = OrderedDict(repos)
branches_to_merge = ['master', 'devel']
unified_repo = 'Maidbot'

this_dir = os.path.dirname(os.path.abspath(__file__))
template_dir = os.path.join(this_dir, 'template')


def call(cmd, *args, **kwargs):
    print("++ {0}".format(' '.join([c if ' ' not in c
                                    else "'{0}'".format(c) for c in cmd])))
    subprocess.check_call(cmd, *args, **kwargs)


def copy_file(src, dst):
    print("++ Copying '{0}'".format(src))
    shutil.copy(src, dst)


def template_file(src, dst, subs):
    print("++ Templating '{0}'".format(src))
    with open(src, 'r') as f:
        data = f.read()
    for k, v in subs.items():
        data = data.replace(k, v)
    with open(dst, 'w+') as f:
        f.write(data)


def main():
    if os.path.exists(unified_repo):
        print("Warning! '{0}' exists, it will be removed in 5 seconds..."
              .format(os.path.abspath(unified_repo)), file=sys.stderr)
        time.sleep(5)
        shutil.rmtree(unified_repo)

    print("\n==> Creating git repository '{0}' to merge repositories into."
          .format(unified_repo))
    os.makedirs(unified_repo)
    os.chdir(unified_repo)
    call(['git', 'init', '.'])
    call(['git', 'commit', '-m', 'Initial commit before merging branches',
          '--allow-empty'])
    call(['git', 'branch', '-m', 'master', 'merge-master'])

    # Merge all repos into unified repo
    for branch in branches_to_merge:
        # For each branch to be merged, setup a local branch to merge into.
        print("\n==> Preparing branch '{0}'".format(branch))
        call(['git', 'checkout', '-b', branch, 'merge-master'])
        call(['git', 'tag', branch + '/initial'])

        print("\n==> Merging imported branches for branch '{0}'".format(branch))
        for repo, repo_data in repos_to_merge.iteritems():
            addr, base_path = repo_data['url'], repo_data['base_path']
            print("==> Processing '{0}' branch from the '{1}' repository"
                  .format(branch, repo))
            temp_branch = 'temp' + '/' + repo + '/' + branch
            call(['git', 'checkout', '-b', temp_branch, branch + '/initial'])

            # For pre 2.7.4
            if git_pre_274:
                call(['git', 'pull', addr, branch, '--no-edit'])
            else:
                call(['git', 'pull', addr, branch,
                      '--allow-unrelated-histories', '--no-edit'])

            package_path = os.path.join(base_path, repo)
            call(['git', 'filter-branch', '-f', '--tree-filter',
                  'mkdir -p __tmp; '
                  'test "$(ls -A | grep -v __tmp)" && '
                  'mv $(ls -A | grep -v __tmp) __tmp && '
                  'mkdir -p ./{0} && '
                  'mv __tmp {1} || true'
                  .format(base_path, package_path),
                  'HEAD'])
            print("==> Merging '{0}' branch from the '{1}' repository"
                  .format(branch, repo))
            call(['git', 'checkout', branch])

            # For pre 2.7.4
            if git_pre_274:
                call(['git', 'merge', '-X', 'theirs', temp_branch, '--no-edit'])
            else:
                call(['git', 'merge', '-X', 'theirs', temp_branch,
                      '--allow-unrelated-histories', '--no-edit'])

            call(['git', 'branch', '-d', temp_branch])
            trashed_files = False
            if os.path.isfile(os.path.join(repo, '.gitignore')):
                trashed_files = True
                call(['git', 'rm', os.path.join(repo, '.gitignore')])
            if os.path.isfile(os.path.join(repo, '.travis.yml')):
                trashed_files = True
                call(['git', 'rm', os.path.join(repo, '.travis.yml')])
            if trashed_files:
                call(['git', 'commit', '-m',
                      'Removing vestigial files after merging'])

        print("\n==> Moving README.md and .gitignore for branch '{0}'"
              .format(branch))

        copy_file(os.path.join(template_dir, 'README.md'), '.')
        print("WTF: {}".format(template_dir))
        copy_file(os.path.join(template_dir, '.gitignore'), '.')
        os.makedirs(os.path.join(unified_repo, '.github'))
        copy_file(os.path.join(template_dir,
                               '.github/PULL_REQUEST_TEMPLATE.md'),
                  os.path.join(unified_repo,
                               '.github/PULL_REQUEST_TEMPLATE.md'))

        if os.path.isdir(os.path.join(template_dir, branch)):
            for file in os.listdir(os.path.join(template_dir, branch)):
                file_path = os.path.join(template_dir, branch, file)
                if not os.path.isfile(file_path):
                    print("Warning! skipping non-file '{0}'".format(file_path),
                          file=sys.stderr)
                    continue
                copy_file(file_path, '.')
        call(['git', 'add', '.'])
        call(['git', 'commit', '-m', 'Moving README.md and .gitignore'])
        call(['git', 'tag', '-d', branch + '/initial'])

    call(['git', 'branch', '-D', 'merge-master'])

    print("Repository complete.")
    print("Add a remote and push the branches like this:")
    print("")
    print("cd {0}".format(unified_repo))
    print("git remote add origin https://github.com/example/repo.git")
    for branch in branches_to_merge:
        print("git checkout {0}".format(branch))
        print("git push -uf origin {0}".format(branch))


if __name__ == '__main__':
    sys.exit(main())
