#!/bin/bash

set -e
set -x

if [[ "${bosh_target}X" == "X" ]]; then
  echo 'Require $bosh_target, $bosh_username, $bosh_password'
  exit 1
fi

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

cd boshrelease
bosh target ${bosh_target}

apt-get -yy install file # TODO missing from upstream

bosh create release --name postgresql-docker
bosh -n upload release --rebase

# until otherwise need, assume we want to test with latest docker-boshrelease
bosh upload release https://bosh.io/d/github.com/cf-platform-eng/docker-boshrelease

./templates/make_manifest warden broker embedded
bosh -n deploy
