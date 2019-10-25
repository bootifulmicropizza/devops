#!/bin/bash

function validateArgs() {
  if [ -z "$1" ]; then
    echo "The environment must be specified as the first and only parameter."
    exit 1
  fi
}

function verifyAwsCredentials() {
  aws sts get-caller-identity
  if [ "$?" != "0" ]; then
    echo "Could not verify AWS credentials. Please check your AWS_PROFILE."
    exit 1
  fi
}
