######################################################################################################
# Load Ballancer
######################################################################################################

# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "http" {
  name = "rke-tf-lb"
  description = "LB to connect to RKE cluster"
  vip_subnet_id = "7277b9da-15ad-4aca-9b69-da11411dad2b"
}

# Create listener
resource "openstack_lb_listener_v2" "http" {
  name = "listener-http"
  protocol        = "TCP"
  protocol_port   = 6443  
  loadbalancer_id = openstack_lb_loadbalancer_v2.http.id
  depends_on      = [openstack_lb_loadbalancer_v2.http]
}

# Set method for load balance
resource "openstack_lb_pool_v2" "http" {
  name = "pool_http"
  protocol    = "TCP"
  lb_method   = "SOURCE_IP"
  listener_id = openstack_lb_listener_v2.http.id
  depends_on  = [openstack_lb_listener_v2.http]
}

# Add multiple instances to pool
resource "openstack_lb_member_v2" "http" {
  for_each      = openstack_compute_instance_v2.rke-masters.*.name
  address       = openstack_compute_instance_v2.http[each.key].access_ip_v4
  protocol_port = 6443
  pool_id       = openstack_lb_pool_v2.http.id
  # subnet_id     = openstack_networking_subnet_v2.http.id
  depends_on    = [openstack_lb_pool_v2.http]
}

# # Create health monitor for check services instances status
# resource "openstack_lb_monitor_v2" "http" {
#   name        = "monitor_http"
#   pool_id     = openstack_lb_pool_v2.http.id
#   type        = "TCP"
#   delay       = 2
#   timeout     = 2
#   max_retries = 2
#   depends_on  = [openstack_lb_member_v2.http]
# }

# resource "openstack_networking_floatingip_v2" "fip-http" {   FIP part only for external acess?? no need rn TODO
#   pool = "public"
# }

# resource "openstack_networking_floatingip_associate_v2" "fip-http" {
#   floating_ip = openstack_networking_floatingip_v2.fip-http.address
#   port_id = openstack_lb_loadbalancer_v2.http.vip_port_id
# }

# may need this https://github.com/terraform-provider-openstack/terraform-provider-openstack/issues/1100#:~:text=I%20had%20to%20use%20use_octavia%20%3D%20true%20in%20the%20provider%20settings... 
# another example https://github.com/diodonfrost/terraform-openstack-examples/blob/master/04-instance-with-loadbalancer/070-loadbalancer.tf 