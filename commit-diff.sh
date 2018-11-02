#!/bin/bash
set -u

pushd $(cd $(dirname $0); pwd) > /dev/null

DEVELOP_DIFF="develop-diff"
FROM=$DEVELOP_DIFF
DEVELOP="develop"
STAGE="stage"
IS_MERGE=false
#diff_branch=$(git rev-parse --abbrev-ref HEAD)
for committer in y-saeki yo-suzuki oomori koyama 
do
  COMMITTERS+=("--committer=$committer")
done

usage_exit() {
  echo "Usage: `basename $0` [-f] [-d] [-s] [-m]" 1>&2
  echo "[-f] : start commit. default is '${DEVELOP_DIFF}'" 1>&2
  echo "[-d] : develop branch. default is '${DEVELOP}'" 1>&2
  echo "[-s] : stage branch. default is '${STAGE}'" 1>&2
  echo "[-m] : create merge commit on ${DEVELOP_DIFF} branch after execute. default is '${IS_MERGE}'" 1>&2
  echo "" 1>&2
  exit 1
}

while getopts "f:d:s:m" opt; 
do
  case "$opt" in
    d) DEVELOP="${OPTARG}" ;;
    s) STAGE="${OPTARG}" ;;
    m) IS_MERGE="true" ;;
    h)  usage_exit ;;
    \?) usage_exit ;;
  esac
done

find_merge () {
  local commit=$1
  local branch=${2:-HEAD}
  (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 | uniq -f1 -d | sort -n | tail -1 | cut -f2
  return 0
}

make_message () {
  local MESSAGE="Differents commits are"
  while read rev
  do
    MESSAGE=$MESSAGE"\n"$(git log -1 --pretty=format:"%H %an : %s" $rev)
  done
  echo $MESSAGE
  return 0
}

MESSAGE=$(git rev-list --reverse --topo-order $DEVELOP ^$FROM ^$STAGE ${COMMITTERS[@]} | make_message)
echo "$MESSAGE"

if $IS_MERGE; then
  git checkout $DEVELOP_DIFF || exit $?
  git merge --no-ff -m "$MESSAGE" $DEVELOP
fi

popd > /dev/null
