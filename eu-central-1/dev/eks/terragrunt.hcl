include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  params      = local.common_vars.locals.common_parameters
  environment = local.common_vars.locals.environment_name
  tags        = local.common_vars.locals.common_tags
  eks         = local.common_vars.locals.eks
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "git::ssh://git@github.com/terrafrom-modules.git/terrafrom-modules.git//aws-dev-sandbox/aws/eks?ref=main"
}

inputs = {
  cluster_name            = local.params.cluster_name
  cluster_version         = "1.26"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnet_ids              = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.public_subnets
  cluster_endpoint_public_access = true

  cluster_addons = local.eks.cluster_addons
  eks_managed_node_group_defaults = local.eks.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks.eks_managed_node_groups

  enable_cluster_creator_admin_permissions = true

  tags = merge(
    local.tags,
    {
      Description = "EKS Cluster for ${local.environment}"
    }
  )
}
