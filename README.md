# arch_k8s
EC2 configs for Kubernetes using OpenTofu

This repo can be used as a module to build your own EC2-based Kubernetes stack in AWS.  Yes, you could use EKS but then you wouldn't learn about all the things that can go wrong and where's the fun in that?

This is written for OpenTofu which was forked from Terraform when it still had a completely open license; you can re-name the `.tofu` files to `.tf` presently and deploy via Terraform (or OpenTofu) but at some point you'll probs need to commit to one or the other.