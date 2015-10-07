#!/bin/bash

echo ls image dir
for image_dir in $(ls docker-image*); do
  echo $image_dir
  ls $image_dir/image
done

echo ls image
for image in $(ls docker-image*/image); do
  echo $image
done
