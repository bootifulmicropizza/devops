#!/bin/bash

. common.sh

validateArgs $@

function run_terraform() {
    ELB=`kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
    cd terraform
    rm -rf .terraform .terraform.lock.hcl
    terraform init -backend-config=config/tf-$1-backend.cfg
    terraform apply -var="environment=$1" -var="loadbalancer_arn=$ELB" --auto-approve
    ECR_REGISTRY_ID=`terraform output -raw ecr_registry_id`
    cd ..
}

export AWS_PROFILE="bootifulmicropizza-$1"
export AWS_REGION=eu-west-1

verifyAwsCredentials

aws eks update-kubeconfig --name bootifulmicropizza --region $AWS_REGION

run_terraform $1

read -p "Update SSM parameters in AWS and then enter to resume ..."

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd patch deployment argocd-server --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["argocd-server", "--insecure", "--staticassets", "/shared/app"] }]'
cat argocd-gateway.yaml | sed "s#DOMAIN_NAME#$DOMAIN_NAME#g" | kubectl apply -n argocd -f -

# https://www.browserling.com/tools/bcrypt
ARGOCD_PWD=`aws ssm get-parameter --name "/argocd/argocdPassword" --with-decryption --query "Parameter.Value" --output text`
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$ARGOCD_PWD'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# TODO
# helm upgrade -i -f helm/values.yaml argocd argocd/argocd --namespace devops --wait

# Install bootifulmicropizza Application

# MANUAL STEP FROM WITHIN THE bootifulmicropizz-app directory
# helm upgrade -i bootifulmicropizza-app . --namespace argocd --wait

#helm upgrade -i bootifulmicropizza-app https://github.com/bootifulmicropizza/v2_bootifulmicropizza-app \
#    --namespace argocd \
#    --wait