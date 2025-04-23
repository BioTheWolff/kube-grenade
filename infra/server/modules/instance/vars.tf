variable "name" {
  description = "OpenStack instance name"
  type        = string
}

variable "instance_flavor" {
  description = "OpenStack instance flavor name"
  default     = "m1.medium"
  type        = string
}

variable "instance_image" {
  description = "OpenStack instance image name"
  default     = "CentOS-9"
  type        = string
}

variable "keypair" {
  description = "OpenStack instance keypair name"
  type        = string
}

variable "secgroup" {
  description = "OpenStack network security group name"
  type        = string
}

variable "network_id" {
  description = "OpenStack network name"
  type        = string
}

variable "user_data_path" {
  description = "Path to the cloud-init user data template file"
  type        = string
}

variable "role" {
  description = "The Ansible role for this instance"
  type        = string
}

variable "ansible_extra_vars" {
  description = "Extra variables to pass to the Ansible playbook"
  default     = {}
}
