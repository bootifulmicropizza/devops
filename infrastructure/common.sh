#!/bin/bash

function verifyAwsCredentials() {
  aws sts get-caller-identity
  if [ "$?" != "0" ]; then
    echo "Could not verify AWS credentials. Please check your AWS_PROFILE."
    exit 1
  fi
}
