#!/bin/zsh

set -e
cd "$(dirname "$0")"

read "TAG?Tag: "
NAME="mgh35/hello-world:$TAG"

printf "Building image: %s" "$NAME"
docker build --tag "$NAME" .

docker login
docker push "$NAME"
