#!/bin/bash
set -eu

diff_branch=develop-diff
develop_branch=develop
stage_branch=stage
for committer in y-saeki yo-suzuki oomori koyama 
do
  committers+=("--committer=$committer")
done

git checkout $diff_branch

from=$(git log --merges -1 --format=%H)

(git rev-list --reverse --topo-order --no-merges $from^2..$develop_branch ${committers[@]} --ancestry-path | cat -n; git rev-list --reverse --topo-order --no-merges $from^2..$stage_branch --first-parent | cat -n) | sort -k2 | uniq -f1 -u | sort -n | cut -f2 | while read rev 
do
  #git log -1 --oneline $rev || break
  git cherry-pick -Xtheirs -x $rev || break 
done 

git merge --no-ff --log -m "Merge branch '${develop_branch}' into ${diff_branch}" $develop_branch
