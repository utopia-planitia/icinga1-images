#!/bin/bash

echo wait for server port
until timeout 1 bash -c 'cat < /dev/null > /dev/tcp/server/80' 2> /dev/null; do sleep 1; done

echo wait for client port
until timeout 1 bash -c 'cat < /dev/null > /dev/tcp/client/5666' 2> /dev/null; do sleep 1; done
