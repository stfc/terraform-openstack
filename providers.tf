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

  resource "openstack_compute_instance_v2" "instance" {
    name              = "${var.VM_name}"
    image_id          = "${var.image_id}"
    flavor_name       = "${var.flavor_name}"
    key_pair          = "${var.key_pair}"
    security_groups   = ["default"]
  
    block_device {
      uuid                  = "${var.image_id}"
      source_type           = "image"
      destination_type      = "local"
      boot_index            = 0
      delete_on_termination = true
    }
  
    block_device {
      source_type           = "blank"
      destination_type      = "volume"
      volume_size           = 1
      boot_index            = 1
      delete_on_termination = true
    }

    network {
      name = "Internal"
    }
  }