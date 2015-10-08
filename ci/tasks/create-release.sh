#!/bin/bash

if [[ "${bosh_target}X" == "X" ]]; then
  echo 'Require $bosh_target, $bosh_username, $bosh_password'
  exit 1
fi

mkdir -p boshrelease/blobs/docker-images

for image in $(ls docker-image*/image); do
  echo $image
  cp $image boshrelease/blobs/docker-images/
done

cd boshrelease
bosh create release

cat > ~/.bosh_config << EOF
---
aliases:
  target:
    bosh-lite: ${bosh_target}
auth:
  ${bosh_target}:
    username: ${bosh_username}
    password: ${bosh_password}
EOF
bosh target ${bosh_target}

bosh -n upload release --rebase
