include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws//.?version=20.8.4"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
}

inputs = {
  cluster_name    = "${local.env}-eks-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  cluster_addons = {
    eks-pod-identity-agent = { most_recent = true }
    core-dns               = { most_recent = true }
    kube-proxy             = { most_recent = true }
    vpc-cni                = { most_recent = true }
  }

  eks_managed_node_groups = {
    system_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]

      labels = {
        "role"        = "system-components"
        "Environment" = local.env
      }
    }
  }

  enable_irsa = true

}