#!/bin/sh -l

# Load .env as environment variables
if [ -f .env ]
then
  export $(cat .env | xargs)
fi

set -eu

# Create with GIT_CRYPT_KEY="$(git-crypt export-key -- - | openssl base64 -A)"
echo "$GIT_CRYPT_KEY" | base64 -d > ./git-crypt-key

git-crypt unlock ./git-crypt-key

rm ./git-crypt-key