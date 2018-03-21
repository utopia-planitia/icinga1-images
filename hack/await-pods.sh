#!/bin/bash

sleep 1

echo -n waiting for server
for _ in {1..150}; do # timeout for 5 minutes
  if kubectl -n alerting -l app=server get po | grep Running | grep 1/1 > /dev/null 2>&1; then
      echo " done"
      break
  fi
  echo -n .
  sleep 2
done

echo -n waiting for client
for _ in {1..150}; do # timeout for 5 minutes
  if kubectl -n alerting -l app=client get po | grep Running | grep 1/1 > /dev/null 2>&1; then
      echo " done"
      break
  fi
  echo -n .
  sleep 2
done
