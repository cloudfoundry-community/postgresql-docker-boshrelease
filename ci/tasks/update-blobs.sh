#!/bin/bash

if [[ "${bosh_target}X" == "X" || "${aws_access_key_id}X" == "X" ]]; then
  echo 'Require $bosh_target, $bosh_username, $bosh_password, $aws_access_key_id, $aws_secret_access_key'
  exit 1
fi

mkdir -p boshrelease/blobs/docker-images

for image in $(ls docker-image*/image); do
  echo $image
  cp $image boshrelease/blobs/docker-images/
done

cd boshrelease

bosh -n upload blobs

if [[ -z "$(git config --global user.name)" ]]
then
  git config --global user.name "Concourse Bot"
  git config --global user.email "concourse-bot@starkandwayne.com"
fi

git commit -a -m "updated docker image blobs"
