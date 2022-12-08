terraform {

    required_version = ">= 0.14.0"

    required_providers {
        openstack = {
            source = "terraform-provider-openstack/openstack"
            version = "~> 1.35.0"
          }
    }
}

provider "openstack" {
  }

  resource "openstack_compute_instance_v2" "exec" {

    name            = "exec-${count.index}"
    image_name        = var.image_name
    flavor_name       = var.flavor_name
    key_pair        = var.key_pair
    security_groups = ["default"]
    count           = var.number_of_VMs
  
    network {
      name = "Internal"
    }
  }