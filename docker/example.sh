#!/bin/zsh

CONTAINER=$(docker run -d -p 5678:5678 hashicorp/http-echo -text="hello world")

curl http://localhost:5678

docker kill $CONTAINER
