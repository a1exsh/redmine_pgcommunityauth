#!/bin/sh
set -e

docker build -t redmine-pgcommunityauth:dev .
docker run -it --rm --network=host redmine-pgcommunityauth:dev
