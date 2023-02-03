######################################################################################################
# Load Ballancer
######################################################################################################

# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "rke-tf-lb" {
  name = "rke-tf-lb"
  description = "LB to connect to RKE cluster"
  vip_subnet_id = ""
  admin_state_up = "true"
  #security_group_ids = openstack_compute_secgroup_v2.rke-secgroup.id
}

# Create listener
resource "openstack_lb_listener_v2" "listener-http" {
  name = "listener-http"
  protocol        = "TCP"
  protocol_port   = 6443  
  loadbalancer_id = openstack_lb_loadbalancer_v2.rke-tf-lb.id
  depends_on      = [openstack_lb_loadbalancer_v2.rke-tf-lb]
}

# Set method for load balance
resource "openstack_lb_pool_v2" "pool_http" {
  name = "pool_http"
  protocol    = "TCP"
  lb_method   = "SOURCE_IP"
  listener_id = openstack_lb_listener_v2.listener-http.id
  depends_on  = [openstack_lb_listener_v2.listener-http]
}

resource "openstack_lb_members_v2" "member_http" {      
  pool_id = openstack_lb_pool_v2.pool_http.id
  
  dynamic "member" {
    for_each = openstack_compute_instance_v2.rke-masters
    content {
      address       = member.value.network[0].fixed_ip_v4
      protocol_port = 6443
    }
  }
}

# Create health monitor for check services instances status
resource "openstack_lb_monitor_v2" "monitor_http" {
  name        = "monitor_http"
  pool_id     = openstack_lb_pool_v2.pool_http.id
  type        = "TCP"
  delay       = 2
  timeout     = 2
  max_retries = 2
  depends_on  = [openstack_lb_members_v2.member_http]
}

resource "openstack_networking_floatingip_v2" "fip-http" {   
  pool = "External"
}

resource "openstack_networking_floatingip_associate_v2" "fip-http" {
  floating_ip = openstack_networking_floatingip_v2.fip-http.address
  port_id = openstack_lb_loadbalancer_v2.rke-tf-lb.vip_port_id
  depends_on = [openstack_networking_floatingip_v2.fip-http]
}