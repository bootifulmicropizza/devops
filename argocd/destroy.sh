#!/bin/bash

. common.sh

validateArgs $@

function run_terraform() {
    ELB=`kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
    cd terraform
    rm -rf .terraform .terraform.lock.hcl
    terraform init -backend-config=config/tf-$1-backend.cfg
    terraform destroy -var="environment=$1" -var="loadbalancer_arn=$ELB" --auto-approve
    cd ..
}

export AWS_PROFILE="bootifulmicropizza-$1"
export AWS_REGION=eu-west-1

verifyAwsCredentials

aws eks update-kubeconfig --name bootifulmicropizza --region $AWS_REGION

kubectl delete -n argocd -f argocd-gateway.yaml
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd

run_terraform $1
