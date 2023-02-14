variable "fedID" {
    default = "${}"
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
    default = 5 
}

variable "worker_count" {
    default = 4
}

variable "security_groups" {
    default = ["rke-secgroup"] 
}

variable "key_pair_name" {
    default = "minimal-key"
}