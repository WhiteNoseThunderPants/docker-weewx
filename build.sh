#!/usr/bin/env bash
VERSION=4.0.0

docker build -t mitct02/weewx:$VERSION .
docker tag mitct02/weewx:$VERSION mitct02/weewx:latest
docker push mitct02/weewx:$VERSION
