# Bootiful Micro Pizza - DevOps

This repo contains the DevOps tooling using Terraform where possible for provisioning. The tooling is split into several directories as detailed below.

- `infrastructure` directory contains the Terraform to create the required shared infrastructure required in the 'devops' AWS account. This is required to be applied before the remaining directories can be installed to the 'devops' account.

- `jenkins` directory contains everything required for installation of Jenkins to the EKS cluster using the Jenkins Helm.

- `argocd` directory contains everything required for installation of ArgoCD to the EKS cluster. ArgoCD provides the continuous delivery.
