variable "fedID" {
    default = ""
} 

variable "image" {
    default = "ubuntu-focal-20.04-nogui"
}

# Used by the load balancer too
variable "master_flavour" {
    default = "l3.nano"
}

variable "worker_flavour" {
    default = "l3.nano"
}

variable "master_count" {
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