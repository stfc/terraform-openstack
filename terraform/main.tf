variable "fedID" {
    default = ""
} 

variable "image" {
    default = "ubuntu-focal-20.04-nogui"
}

# Used by the load balancer too
variable "controller_flavour" {
    default = "l3.nano"
}

variable "worker_flavour" {
    default = "l3.nano"
}

variable "controller_count" {
    default = 3 # Need to update to load balancer definitions below when this changes to include the extra ips as they are not dynamic
}

variable "worker_count" {
    default = 1
}

variable "security_groups" {
    default = ["rke-secgroup"] # later we want to set to  default = ["rke-secgroup", "your-own-secgroup"]
}

variable "key_pair_name" {
    default = "minimal-key"
}

######################################################################################################
# Security Groups
######################################################################################################

resource "openstack_compute_secgroup_v2" "rke-secgroup" {
  name        = "rke-secgroup"
  description = "security group for RKE2 service"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 9345
    to_port     = 9345
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2379
    to_port     = 2379
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2380
    to_port     = 2380
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 30000
    to_port     = 32767
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 4240
    to_port     = 4240
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8
    to_port     = 8
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 179
    to_port     = 179
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 4789
    to_port     = 4789
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 5473
    to_port     = 5473
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 9098
    to_port     = 9098
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 9099
    to_port     = 9099
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 5473
    to_port     = 5473
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

######################################################################################################
# SSH Keys
######################################################################################################

# resource "openstack_compute_keypair_v2" "keypair" {
#   name = "vxw59196" # Use fedID 
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE973x4riglYeO/8QRF2Pbr0rb7W4Q40apqJf1UUnBnKZ04wPmPq9R+20JDt/YpX4i+Nfxv8peFu6+wqrdHLbNWTnQoUq+jWGass5MzadWhaW8Bc8BRuMgCx3dBxLnHKAH9Lrr9PKhY99w2573B8sb5SdJKDJQMCqjpVlQKtgOaJEHZ3iE9eBKDj0z+FveIpA/huLFPXeLmYc3u/DpGgkc59x5xnLPuh4Va0IJ+9DEsru5NYFLVACVW8QsNozWYONs/2xUjO4uL1Ue5wfFoRWU87lgJ8YZNXj1aszrJD4i51cD8Zar1dbHc2CHMDF0oyJBpXd6IfN4F5R4MUVizmtD samuel.jones@stfc.ac.uk"
# }

######################################################################################################
# Nodes
######################################################################################################

resource "openstack_compute_instance_v2" "rke-controllers" {
  name = "rke-controller-${count.index+1}"
  image_name = var.image
  flavor_name = var.controller_flavour
  key_pair = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.rke-secgroup.name] # var.security_groups TODO
  count = var.controller_count

  network {
    name = "Internal"
  } 
}

resource "openstack_compute_instance_v2" "rke-workers" {
  name = "rke-worker-${count.index+1}"
  image_name = var.image
  flavor_name = var.worker_flavour
  key_pair = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.rke-secgroup.name] # var.security_groups TODO
  count = var.worker_count

  network {
    name = "Internal"
  } 
}

resource "openstack_compute_instance_v2" "rke-load-balancer" {
    name = "rke-load-balancer"
    image_name = var.image
    flavor_name = var.controller_flavour
    key_pair = var.key_pair_name
    security_groups = [openstack_compute_secgroup_v2.rke-secgroup.name] # var.security_groups TODO

  network {
    name = "Internal"
  } 
}

######################################################################################################
# output
######################################################################################################

output "ansible_inventory" {
  value = templatefile(
    "${path.module}/templates/ansible-inventory.tftpl",
    {
        user = var.fedID       
        controllers = openstack_compute_instance_v2.rke-controllers.*.access_ip_v4,
        workers = openstack_compute_instance_v2.rke-workers.*.access_ip_v4
        load-balancer = openstack_compute_instance_v2.rke-load-balancer.access_ip_v4
    }
  )
}

output "haproxy_config" {
    value = templatefile(
        "${path.module}/templates/haproxy.tftpl",
        {
            controller1 = openstack_compute_instance_v2.rke-controllers[0].access_ip_v4,
            controller2 = openstack_compute_instance_v2.rke-controllers[1].access_ip_v4,
            controller3 = openstack_compute_instance_v2.rke-controllers[2].access_ip_v4
        }
    )
}