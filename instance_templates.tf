# instance_templates.tf

locals {
  # Instance Templates definition
  instance_templates = {
    "central-cluster" = { # Name Prefix of each Instance Template 
      name         = "central-cluster"
      region       = var.region
      preemptible  = false
      disk_type    = "pd-balanced"
      disk_size_gb = "100"
      auto_delete  = true
      source_image = "centos-7"
      machine_type = "n1-standard-1"
      tags         = ["ssh"]
      labels = {
        cluster = "central"
      }
      subnetwork = "main-cni-subnet"
      # additional_networks = [{
      #   network            = "multus-vpc"
      #   subnetwork         = "multus-subnet"
      #   subnetwork_project = var.project_id
      #   network_ip         = ""
      #   access_config = [{
      #     nat_ip       = null
      #     network_tier = null
      #   }]
      # }]
      startup_script = file("scripts/startup_central.sh")
      service_account = {
        email  = "compute-general@${var.project_id}.iam.gserviceaccount.com"
        scopes = []
      }
    },
    "edge-cluster" = { # Name Prefix of each Instance Template 
      name         = "edge-cluster"
      region       = var.region
      preemptible  = false
      disk_type    = "pd-balanced"
      disk_size_gb = "100"
      auto_delete  = true
      source_image = "centos-7"
      machine_type = "n1-standard-1"
      tags         = ["ssh"]
      labels = {
        cluster = "edge"
      }
      subnetwork = "main-cni-subnet"
      # additional_networks = [{
      #   network            = "multus-vpc"
      #   subnetwork         = "multus-subnet"
      #   subnetwork_project = var.project_id
      #   network_ip         = ""
      #   access_config = [{
      #     nat_ip       = null
      #     network_tier = null
      #   }]
      # }]
      startup_script = file("scripts/startup_edge.sh")
      service_account = {
        email  = "compute-general@${var.project_id}.iam.gserviceaccount.com"
        scopes = []
      }
    }
  }
}

# Instance Templates Creation
module "instance_templates" {
  for_each     = { for instance_templates in local.instance_templates : "${instance_templates.name}" => instance_templates }
  source       = "terraform-google-modules/vm/google//modules/instance_template"
  project_id   = var.project_id
  name_prefix  = each.key
  region       = each.value.region
  preemptible  = each.value.preemptible
  disk_type    = each.value.disk_type
  disk_size_gb = each.value.disk_size_gb
  auto_delete  = each.value.auto_delete
  source_image = each.value.source_image
  machine_type = each.value.machine_type
  tags         = each.value.tags
  labels       = each.value.labels
  subnetwork   = each.value.subnetwork
  # additional_networks = each.value.additional_networks
  subnetwork_project = var.project_id
  startup_script     = each.value.startup_script
  service_account    = each.value.service_account
  depends_on         = [module.subnets, module.service_accounts]
}
