#!/bin/bash

set -e

if [ ! -f "$2.tar" ]; then
  echo "downloading $1" 
  docker pull "$1"
  echo "exporting $1 to $2.tar" 
  docker save "$1" -o "$2.tar"
fi
echo "importing $2.tar" 
docker load -i "$2.tar"
