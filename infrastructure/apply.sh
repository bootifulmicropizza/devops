#!/bin/bash

. common.sh

function run_terraform() {
    rm -rf .terraform .terraform.lock.hcl
    terraform init
    terraform apply --auto-approve
    CERTIFICATE_ARN=`terraform output -raw certificate_arn`
}

export AWS_PROFILE="bootifulmicropizza-devops"
export AWS_REGION=eu-west-1

verifyAwsCredentials

run_terraform

aws eks update-kubeconfig --name bootifulmicropizza --region $AWS_REGION

# Install Istio
ISTIO_VERSION=1.9.0
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=x86_64 sh -
istio-$ISTIO_VERSION/bin/istioctl install -y

# Update Istio system service with ACM configuration
kubectl -n istio-system patch service istio-ingressgateway --patch "$(cat istio-system-service-patch.yaml | sed "s#CERTIFICATE_ARN#$CERTIFICATE_ARN#g")"
