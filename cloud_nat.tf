# cloud_nat.tf

locals {
  # Cloud NAT definition
  cloud_nat = {
    "nat-router" = { # Name of each Cloud Nat instance
      region        = var.region
      create_router = true
      network       = "main-cni-vpc"
      router        = "nat-router"
    }
  }
}

# Cloud NAT Creation
module "cloud-nat" {
  for_each      = local.cloud_nat
  source        = "terraform-google-modules/cloud-nat/google"
  project_id    = var.project_id
  name          = each.key
  region        = each.value.region
  create_router = each.value.create_router
  network       = each.value.network
  router        = each.value.router
  depends_on    = [module.vpcs]
}
