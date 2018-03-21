#!/bin/bash

kubectl -n alerting delete po --all

source ./hack/await-pods.sh
