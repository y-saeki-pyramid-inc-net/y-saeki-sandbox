#!/bin/bash
set -eu

find_merge () {
  local commit=$1
  local branch=${2:-HEAD}
  (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 | uniq -f1 -d | sort -n | tail -1 | cut -f2
  return 0
}

diff_branch=$(git rev-parse --abbrev-ref HEAD)
develop_branch=develop
#develop_from=$(find_merge $develop_branch $diff_branch) 
#if [ -z "$develop_from" ]; then
#  develop_from=$diff_branch
#fi
stage_branch=stage
#stage_from=$(find_merge $stage_branch $develop_branch)
for committer in y-saeki yo-suzuki oomori koyama 
do
  committers+=("--committer=$committer")
done

#(git rev-list --reverse --topo-order --no-merges $develop_from^2..$develop_branch ${committers[@]} --ancestry-path | cat -n; git rev-list --reverse --topo-order --no-merges $stage_from^2..$stage_branch --first-parent | cat -n) | sort -k2 | uniq -f1 -u | sort -n | cut -f2 | while read rev
git rev-list --reverse --topo-order $develop_branch ^$diff_branch ^$stage_branch ${committers[@]} | while read rev
do
  #git log -1 --oneline $rev || break
  git cherry-pick -Xtheirs -x $rev || break 
done 

git merge --no-ff --log -m "Merge branch '${develop_branch}' into ${diff_branch}" $develop_branch
