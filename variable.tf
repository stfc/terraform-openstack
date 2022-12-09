// Enter all necessary details regarding your deployment

variable "key_pair" {
default = "ubuntu-laptop"
}

variable "VM_name" {
default = "openstack-VM"
}

variable "vol_name" {
default = "test-tf-vol"	
}

variable "vol_size" {
default = "1"		
}

variable "number_of_VMs" {
default = "1"
}

variable "image_id" {
default = "0eedaf19-2ead-44bf-84e4-3334ad772da1" //ubuntu-focal-20.04-nogui
}
// "0e50b86d-f923-4cfa-a96b-17086258521e" scientificlinux-7-nogui
// "49669b19-2ac9-4578-ae11-01af778fa447" ubuntu-focal-20.04-gui

variable "flavor_name" {
default = "l3.nano"
}
// c3.small
// l2.small