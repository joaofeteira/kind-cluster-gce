# compute_instances.tf

locals {
  # Compute Instances definition
  compute_instances = {
    "central-cluster" = { # Prefix for each Compute Instance
      name                = "central-cluster"
      region              = var.region
      zone                = var.zone
      num_instances       = 2
      instance_template   = module.instance_templates["central-cluster"].self_link
      deletion_protection = false # Protect the instance from deletion
    }
    "edge-cluster" = {
      name                = "edge-cluster"
      region              = var.region
      zone                = var.zone
      num_instances       = 2
      instance_template   = module.instance_templates["edge-cluster"].self_link
      deletion_protection = false # Protect the instance from deletion
    }
  }
}

# Compute Instances Creation
module "compute_instances" {
  for_each            = { for compute_instances in local.compute_instances : "${compute_instances.name}" => compute_instances }
  source              = "terraform-google-modules/vm/google//modules/compute_instance"
  hostname            = each.key
  region              = each.value.region
  zone                = each.value.zone
  subnetwork_project  = var.project_id
  num_instances       = each.value.num_instances
  instance_template   = each.value.instance_template
  deletion_protection = each.value.deletion_protection
  depends_on          = [module.subnets, module.service_accounts]
}
