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

resource "openstack_compute_instance_v2" "rke-masters" {
  name = "rke-master-${count.index+1}"
  image_name = var.image
  flavor_name = var.master_flavour
  key_pair = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.rke-secgroup.name] # var.security_groups TODO
  count = var.master_count

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

######################################################################################################
# output
######################################################################################################

output "ansible_inventory" {
  value = templatefile(
    "${path.module}/templates/ansible-inventory.tftpl",
    {
        user = var.fedID,       
        masters = openstack_compute_instance_v2.rke-masters.*.access_ip_v4,
        workers = openstack_compute_instance_v2.rke-workers.*.access_ip_v4
    }
  )
}