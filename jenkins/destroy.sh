#!/bin/bash

. common.sh

validateArgs $@

function run_terraform() {
    ELB=`kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
    ELB_ZONE=`aws elb describe-load-balancers --query "LoadBalancerDescriptions[?DNSName=='$ELB'].CanonicalHostedZoneNameID" --output text`
    OPEN_ID_PROVIDER_ARN=`aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[0].Arn" --output text`
    OPEN_ID_PROVIDER_URL=`aws iam get-open-id-connect-provider --open-id-connect-provider-arn $OPEN_ID_PROVIDER_ARN --query "Url" --output text`

    cd terraform
    rm -rf .terraform .terraform.lock.hcl
    terraform init -backend-config=config/tf-$1-backend.cfg
    terraform destroy \
        -var="environment=$1" \
        -var="loadbalancer_arn=$ELB" \
        -var="loadBalancer_zone=$ELB_ZONE" \
        -var="openIdProviderArn=$OPEN_ID_PROVIDER_ARN" \
        -var="openIdProviderUrl=$OPEN_ID_PROVIDER_URL" \
        --auto-approve
    cd ..
}

export AWS_PROFILE="bootifulmicropizza-$1"
export AWS_REGION=eu-west-1
EKS_CLUSTER_NAME=bootifulmicropizza

verifyAwsCredentials

aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

helm uninstall bootifulmicropizza-jenkins --namespace devops
kubectl -n devops patch pvc jenkins-pvc -p '{"metadata":{"finalizers": []}}' --type=merge

run_terraform $1
