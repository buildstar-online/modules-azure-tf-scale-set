variable "environment" {
  type = string
}

variable "cloud-init-path" {
  type = string
}

variable "keyvault_id" {
  type = string
}

variable "scale_set_name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_sku" {
  type = string
}

variable "vm_instances" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "vm_name_prefix" {
  type = string
}

variable "vm_network_interface" {
  type = string
}

variable "vm_disk_caching" {
  type = string
}

variable "vm_storage_account_type" {
  type = string
}

variable "vm_disk_size" {
  type = string
}

variable "vm_source_image_publisher" {
  type = string
}

variable "vm_source_image_offer" {
  type = string
}

variable "vm_source_image_sku" {
  type = string
}

variable "vm_source_image_verson" {
  type = string
}

variable "storage_account_url" {
  type = string
}

variable "admin_users" {
  type = list(string)
}

variable "vnet_subnet_name" {
  type = string
}

variable "vm_net_iface_name" {
  type = string
}

variable "vm_net_iface_ipconfig_name" {
  type = string
}

variable "vm_net_iface_private_ip_address_allocation" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_prefixes" {
  type = list(string)
}

variable "allowed_ips" {
  type = list(string)
}

variable "network_security_group_id" {
  type = string
}
