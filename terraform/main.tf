######################################################################################################
# Nodes
######################################################################################################

resource "openstack_compute_instance_v2" "rke-masters" {
  name = "rke-master-${count.index+1}"
  image_name = var.image
  flavor_name = var.master_flavour
  key_pair = var.key_pair_name
  security_groups = [openstack_compute_secgroup_v2.rke-secgroup.name] 
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
  security_groups = [openstack_compute_secgroup_v2.rke-secgroup.name]
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
        user = "${var.OS_USERNAME}",       
        masters = openstack_compute_instance_v2.rke-masters.*.access_ip_v4,
        workers = openstack_compute_instance_v2.rke-workers.*.access_ip_v4
    }
  )
}