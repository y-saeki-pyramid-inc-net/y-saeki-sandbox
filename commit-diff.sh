#!/bin/bash
set -eu

diff_branch=develop-diff
develop_branch=develop
stage_branch=stage

#git rev-list --reverse --topo-order --no-merges --committer=y-saeki --ancestry-path $diff_branch^2..$develop_branch | while read rev 
(git rev-list --reverse --topo-order --no-merges $diff_branch^2..$develop_branch --ancestry-path | cat -n; git rev-list --reverse --topo-order --no-merges $diff_branch^2..$stage_branch --first-parent | cat -n) | sort -k2 | uniq -f1 -n | sort -n | cut -f2 | while read rev 
do
  git log -1 --oneline $rev || break
  #git cherry-pick -Xtheirs -x $rev || break 
done 
