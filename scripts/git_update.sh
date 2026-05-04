#!/bin/bash

VERSION=""

# get parameters
while getopts v: flag
do
  case "${flag}" in
    v) VERSION=${OPTARG};;
  esac
done

# get highest tag number
git fetch --prune --unshallow 2>/dev/null
CURRENT_VERSION=$(git describe --abbrev=0 --tags 2>/dev/null)

if [[ -z "$CURRENT_VERSION" ]]
then
  CURRENT_VERSION='v0.1.0'
fi

echo "Current Version: $CURRENT_VERSION"

# remove 'v'
CURRENT_VERSION=${CURRENT_VERSION#v}

# split into array
IFS='.' read -r VNUM1 VNUM2 VNUM3 <<< "$CURRENT_VERSION"

# increment
if [[ $VERSION == 'major' ]]
then
  VNUM1=$((VNUM1+1))
  VNUM2=0
  VNUM3=0
elif [[ $VERSION == 'minor' ]]
then
  VNUM2=$((VNUM2+1))
  VNUM3=0
elif [[ $VERSION == 'patch' ]]
then
  VNUM3=$((VNUM3+1))
else
  echo "Invalid version type. Use: major, minor, patch"
  exit 1
fi

# add 'v' back here
NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"

echo "($VERSION) updating to $NEW_TAG"

# check if current commit already has a tag
GIT_COMMIT=$(git rev-parse HEAD)
NEEDS_TAG=$(git describe --contains $GIT_COMMIT 2>/dev/null)

if [ -z "$NEEDS_TAG" ]; then
  echo "Tagged with $NEW_TAG"
  git tag $NEW_TAG
  git push origin $NEW_TAG
else
  echo "Already a tag on this commit"
fi

echo "new-tag=$NEW_TAG" >> $GITHUB_OUTPUT