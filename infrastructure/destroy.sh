#!/bin/bash

. common.sh

function run_terraform() {
    cd terraform
    rm -rf .terraform .terraform.lock.hcl
    terraform init
    terraform destroy --auto-approve
    cd ..
}

export AWS_PROFILE="bootifulmicropizza-$1"
export AWS_REGION=eu-west-1

verifyAwsCredentials

echo "Deleting ELB..."
ELB=`aws elb describe-load-balancers --query "LoadBalancerDescriptions[0].LoadBalancerName" --output text`
aws elb delete-load-balancer --load-balancer-name $ELB

run_terraform
