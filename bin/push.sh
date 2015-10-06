#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
export GIT_COMMITTER_NAME="Yoshiaki Kawazu"
export GIT_COMMITTER_EMAIL="kawazzz@gmail.com"
export GIT_AUTHOR_NAME="Yoshiaki Kawazu"
export GIT_AUTHOR_EMAIL="kawazzz@gmail.com"

# data以下を全部commit
git add data/
git commit -m "Updated price" data/

# GH_TOKEN がセットされてたらGithubへpushする
[[ -z $GH_TOKEN ]] && { echo 'Please set GH_TOKEN' >&2; exit 1; }
REPO="https://${GH_TOKEN}@github.com/kawaz/aws-pricing"
BRANCH="master"
git push --quiet -f "$REPO" "$BRANCH"
