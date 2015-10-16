#!/bin/bash

set -e

# change to root of bosh release
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/../..

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

bosh download manifest ${deployment_name} /tmp/${deployment_name}.yml
bosh deployment /tmp/${deployment_name}.yml

bosh run errand ${errand}
