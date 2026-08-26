include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/eks-data-addons/aws//.?version=1.31.0"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "${local.env}-eks-cluster"
  }
}

dependency "sqs" {
  config_path = "../sqs"

  mock_outputs = {
    queue_arn = "arn:aws:sqs:us-east-1:123456789012:my-queue"
  }
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name

  # 1. Argo CD installation
  enable_argo_cd = true
  argocd = {
    chart_version = "6.7.0"
    values        = [file("values/argocd-values.yaml")]
  }

  # 2. Karpenter Installation
  enable_karpenter = true
  karpenter = {
    chart_version = "0.35.0"
    repository    = "oci://public.ecr.aws/karpenter"
  }

  # 3. KEDA Installation with SQS Permissions
  enable_keda = true
  keda = {
    chart_version = "2.14.0"
  }

}