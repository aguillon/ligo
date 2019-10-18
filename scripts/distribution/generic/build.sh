#!/bin/sh

dockerfile_name="build"
# Generic dockerfile
dockerfile="./docker/distribution/generic/build.Dockerfile"
. ./scripts/distribution/generic/parameters.sh

echo "Building LIGO for $target"
echo "Using Dockerfile: $dockerfile"
echo "Tagging as: $tag_build\n"
docker build --build-arg target="$target" -t "$tag_build" -f "$dockerfile" .