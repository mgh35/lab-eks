#!/bin/zsh

set -e
cd "$(dirname "$0")"

docker build . --tag hello-world
