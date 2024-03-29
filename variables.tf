variable "environment" {
  type = string
}

variable "user_data_path" {
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

variable "vm_os_disk_caching" {
  type = string
}

variable "vm_os_disk_size_gb" {
  type = string
}

variable "vm_os_storage_account_type" {
  type = string
}

variable "vm_os_disk_write_accelerator_enabled" {
  type = string
}

variable "vm_data_disk_caching" {
  type = string
}

variable "vm_data_disk_size_gb" {
  type = string
}

variable "vm_data_storage_account_type" {
  type = string
}

variable "vm_data_disk_write_accelerator_enabled" {
  type = string
}

variable "vm_data_disk_create_option" {
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

variable "priority" {
  type = string
}

variable "eviction_policy" {
  type = string
}

variable "max_bid_price" {
  type = string
}

variable "overprovision" {
  type = string
}

variable "ultra_ssd_enabled" {
  type = string
}

variable "scale_in_rule" {
  type = string
}

variable "scale_in_force_deletion_enabled" {
  type = string
}

variable "spot_restore_enabled" {
  type = string
}

variable "spot_restore_timeout" {
  type = string
}

variable "username" {
  type    = string
  default = "friend"
}

variable "github_username" {
  type    = string
  default = ""
}

variable "hostname" {
  type    = string
  default = "azurespot"
}

