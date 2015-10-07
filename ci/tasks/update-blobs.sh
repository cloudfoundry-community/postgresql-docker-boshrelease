#!/bin/bash

if [[ "${aws_access_key_id}X" == "X" ]]; then
  echo 'Require $aws_access_key_id, $aws_secret_access_key'
  exit 1
fi


cat > boshrelease/config/private.yml << EOF
---
blobstore:
  s3:
    access_key_id: ${aws_access_key_id}
    secret_access_key: ${aws_secret_access_key}
EOF

cd boshrelease
bosh -n sync blobs
cd -

mkdir -p boshrelease/blobs/docker-images

for image_dir in $(ls docker-image*/image | xargs -L1 dirname); do
  imagename=$(cat $image_dir/repository | sed "s/\//\-/")
  tag=$(cat $image_dir/tag)
  cp $image_dir/image boshrelease/blobs/docker-images/${imagename}-${tag}.tgz
done

cd boshrelease
bosh -n upload blobs

if [[ -z "$(git config --global user.name)" ]]
then
  git config --global user.name "Concourse Bot"
  git config --global user.email "concourse-bot@starkandwayne.com"
fi

git commit -a -m "updated docker image blobs"
