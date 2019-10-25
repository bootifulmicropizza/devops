# Bootiful Micro Pizza - DevOps - Jenkins

Installs Jenkins from Jenkins Helm chart into EKS cluster.

Creates PVC on EFS.

## Get the Jenkins admin password
```
$ printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```

## aws-auth configmap

The Jenkins pod runs as `role/BootifulMicroPizzaJenkinsServiceAccount`.
The Jenkins jobs (cicd-pipeline) run as 'user/jenkins'.

```
mapUsers: |
  - groups:
    - system:masters
    userarn: arn:aws:iam::337036170088:user/jenkins
    username: jenkins
```

## Notes

https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/

### EFS/PVC
https://stackoverflow.com/questions/63809000/aws-eks-with-fargate-pod-status-pending-due-to-persistentvolumeclaim-not-found

https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/deploy/kubernetes/base/csidriver.yaml

### AWS Load balancer ingress

https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
https://github.com/kubernetes-sigs/aws-load-balancer-controller#readme
https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/annotations/#certificate-arn

$ aws eks describe-cluster --name bootifulmicropizza --query "cluster.identity.oidc.issuer" --output text

https://oidc.eks.eu-west-1.amazonaws.com/id/B2FDC98BBFAA7A951043809AE875B176

$ eksctl utils associate-iam-oidc-provider --region=eu-west-1 --cluster=bootifulmicropizza --approve

$ aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

ARN: arn:aws:iam::201655463889:policy/AWSLoadBalancerControllerIAMPolicy

$ eksctl create iamserviceaccount \
  --cluster=bootifulmicropizza \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::201655463889:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

====== 
Role with 'AWSLoadBalancerControllerIAMPolicy' policy plus below trust relationship:
K8S serviceaccount for aws-load-balancer-controller should have annotation: eks.amazonaws.com/role-arn: arn:aws:iam::201655463889:role/eksctl-bootifulmicropizza-addon-iamserviceac-Role1-SL2VEATCLZDZ
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::201655463889:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/9F273D1484F2E126BA4DB2DE7439058B"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.eu-west-1.amazonaws.com/id/9F273D1484F2E126BA4DB2DE7439058B:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
          "oidc.eks.eu-west-1.amazonaws.com/id/9F273D1484F2E126BA4DB2DE7439058B:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
==== 
Role with 'AmazonEKS_CNI_Policy' policy plus below trust relationship:
K8S serviceaccount for aws-node should have annotation: eks.amazonaws.com/role-arn: arn:aws:iam::201655463889:role/eksctl-bootifulmicropizza-addon-iamserviceac-Role1-1TUXZSG667YJD
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::201655463889:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/9F273D1484F2E126BA4DB2DE7439058B"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.eu-west-1.amazonaws.com/id/9F273D1484F2E126BA4DB2DE7439058B:aud": "sts.amazonaws.com",
          "oidc.eks.eu-west-1.amazonaws.com/id/9F273D1484F2E126BA4DB2DE7439058B:sub": "system:serviceaccount:kube-system:aws-node"
        }
      }
    }
  ]
}
====




$ kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

$ helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=bootifulmicropizza \
  --set region=eu-west-1 \
  --set vpcId=vpc-0bee8d19e881112c2 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system

### To delete the PVC
kubectl patch pvc jenkins-pvc -n jenkins -p '{"metadata":{"finalizers": []}}' --type=merge

### Traefik example (LB and proxy)
https://hands-on-tech.github.io/2020/03/15/k8s-jenkins-example.html

### Running docker-in-docker on Fargate - not supported
https://github.com/aws/containers-roadmap/issues/95

### Accessing K8S via Jenkins credential:
https://piotrminkowski.com/2020/11/10/continuous-integration-with-jenkins-on-kubernetes/
