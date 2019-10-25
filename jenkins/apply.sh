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
    terraform apply \
        -var="environment=$1" \
        -var="loadbalancer_arn=$ELB" \
        -var="loadBalancer_zone=$ELB_ZONE" \
        -var="openIdProviderArn=$OPEN_ID_PROVIDER_ARN" \
        -var="openIdProviderUrl=$OPEN_ID_PROVIDER_URL" \
        --auto-approve
    ECR_REGISTRY_ID=`terraform output -raw ecr_registry_id`
    cd ..
}

function build_docker_images() {
    cd docker-images/build-tools-jnlp
    . build.sh $ECR_REGISTRY_ID
    cd ../..
}

export AWS_PROFILE="bootifulmicropizza-$1"
export AWS_REGION=eu-west-1
EKS_CLUSTER_NAME=bootifulmicropizza

verifyAwsCredentials

aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

run_terraform $1
build_docker_images

kubectl create namespace devops

FILE_SYSTEM_ID=`aws efs describe-file-systems --query "FileSystems[?CreationToken=='jenkins_efs'].FileSystemId" --output text`
ACCESS_POINT_ID=`aws efs describe-access-points --query "AccessPoints[?FileSystemId=='$FILE_SYSTEM_ID'].AccessPointId" --output text`

read -p "Update SSM parameters in AWS and then enter to resume ..."

# Install
helm repo add jenkins https://charts.jenkins.io
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update
helm dependency update ./helm/bootifulmicropizza-jenkins
helm upgrade -i bootifulmicropizza-jenkins helm/bootifulmicropizza-jenkins \
    --set fileSystemId=$FILE_SYSTEM_ID \
    --set accessPointId=$ACCESS_POINT_ID \
    --values helm/bootifulmicropizza-jenkins/values.yaml \
    --values helm/bootifulmicropizza-jenkins/values-$1.yaml \
    --namespace devops \
    --wait

# Get the Jenkins admin password
kubectl exec --namespace devops -it bootifulmicropizza-jenkins-0 -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo
