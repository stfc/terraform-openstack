// Enter all necessary details regarding your deployment

variable "key_pair" {
default = "ubuntu-laptop"
}

variable "VM_name" {
default = "openstack-VM"
}

variable "number_of_VMs" {
default = "2"
}

variable "image_name" {
default = "ubuntu-focal-20.04-nogui"
}
// scientificlinux-7-nogui
// ubuntu-focal-20.04-gui

variable "flavor_name" {
default = "l3.nano"
}
// c3.small
// l2.small