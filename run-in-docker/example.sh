#!/bin/zsh

CONTAINER=$(docker run -d -p 5000:5000 hello-world)
printf "Started container: $CONTAINER\n"

printf "Response: $(wget -q -O - http://localhost:5000)\n"

docker kill "$CONTAINER"
