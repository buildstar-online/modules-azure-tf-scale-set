# Azure Scale-Set

A terraform module to create an Azure Scale-Set using Spot VMs with GPUs. Designed for use with this [azure-tf-starter](https://github.com/cloudymax/azure-tf-starter) guide.

Azure Scale-Sets are load-ballanced pools of identical VMs that can be manually or automatically scaled horizontally uo to 1000 VMs or down to 0. Scale-Sets can be created using Spot VMs for significant price discounts (usually 40-80%).


## Coosing a Virtual Machine Type

Azure uses two hypervsisor types. `Gen1` which is based on legacy BIOS, and `Gen2` which is based on UEFI. Many VM families only support one or the other, though some support both. You will need to check [here](https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2) which type is required by the VM family you want to use. You can find the list of Azure's Instance Families [here](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-general). 

Once you know what instance type you're looking for, you can check the current spot pricing [here](https://azure.microsoft.com/en-us/pricing/spot-advisor/). Like all the other major clouds Azure uses quotas. These may be too low for you to create certain types of virtual machines, GPUs, Spot instances, or Low-Priority VMs. You can request quota changes via the portal [here](https://portal.azure.com/#view/Microsoft_Azure_Capacity/QuotaMenuBlade/~/overview).

  > Not every Azure datacenter has every type of machine. You will need to check if the machine you want is availbe in the datacenter you will be using. The example query below can help you check, just change the `size` field to the SKU you want to check.   
  >  ```bash
  >  az vm list-skus --location "westeurope" \
  >    --size Standard_N \
  >    --output table
  >  ```


## Module Usage

```hcl
module "scale-set" {

  source = "github.com/cloudymax/modules-azure-tf-scale-set"

  # Project settings
  environment    = local.environment
  location       = local.location
  resource_group = local.resource_group
  allowed_ips    = local.allowed_ips

  # Scale Set VM settings
  scale_set_name                  = "scale-set"
  vm_sku                          = "Standard_NV6ads_A10_v5"
  vm_instances                    = 1
  priority                        = "Spot"
  spot_restore_enabled            = true
  spot_restore_timeout            = "PT1H30M"
  eviction_policy                 = "Deallocate"
  max_bid_price                   = "0.24"
  overprovision                   = false
  ultra_ssd_enabled               = false
  scale_in_rule                   = "NewestVM"
  scale_in_force_deletion_enabled = true
  cloud_init_path                 = "cloud-init.txt"
  vm_admin_username               = local.admin_identity
  vm_name_prefix                  = "${local.environment}-"
  vm_network_interface            = "vm-nic"

  # Network options
  vnet_name        = module.environment-base.vnet_name
  vnet_subnet_name = "scale-set-subnet"
  subnet_prefixes  = ["192.168.1.0/24"]

  # OS Disk options
  vm_os_disk_caching                   = "ReadWrite"
  vm_os_storage_account_type           = "Premium_LRS"
  vm_os_disk_size_gb                   = "32"
  vm_os_disk_write_accelerator_enabled = false

  # Storage Disk options
  vm_data_disk_caching                   = "None"
  vm_data_storage_account_type           = "PremiumV2_LRS"
  vm_data_disk_size_gb                   = "32"
  vm_data_disk_write_accelerator_enabled = false
  vm_data_disk_create_option             = "Empty"

  # OS Images settings
  vm_source_image_publisher = "Canonical"
  vm_source_image_offer     = "0001-com-ubuntu-server-focal-daily"
  vm_source_image_sku       = "20_04-daily-lts-gen2"
  vm_source_image_verson    = "20.04.202303090"

  # Storage account
  storage_account_url = module.environment-base.storage_account.primary_blob_endpoint

  # Key Vault
  keyvault_id = module.environment-base.kv_id

  # Managed Identity
  admin_users = ["${module.environment-base.managed_identity_id}"]

  # Network Settings
  vm_net_iface_name                          = "vm-nic"
  vm_net_iface_ipconfig_name                 = "vm-nic-config"
  vm_net_iface_private_ip_address_allocation = "Dynamic"
  
}
```

- The terraform documentation for `azurerm_linux_virtual_machine_scale_set` can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.vm_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine_scale_set.scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_network_security_group.scaleset_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet.vm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [random_password.vm_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.vm_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.cloudconfig](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | n/a | `list(string)` | n/a | yes |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | n/a | `list(string)` | n/a | yes |
| <a name="input_cloud_init_path"></a> [cloud\_init\_path](#input\_cloud\_init\_path) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_eviction_policy"></a> [eviction\_policy](#input\_eviction\_policy) | n/a | `string` | n/a | yes |
| <a name="input_keyvault_id"></a> [keyvault\_id](#input\_keyvault\_id) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_max_bid_price"></a> [max\_bid\_price](#input\_max\_bid\_price) | n/a | `string` | n/a | yes |
| <a name="input_overprovision"></a> [overprovision](#input\_overprovision) | n/a | `string` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | n/a | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `string` | n/a | yes |
| <a name="input_scale_in_force_deletion_enabled"></a> [scale\_in\_force\_deletion\_enabled](#input\_scale\_in\_force\_deletion\_enabled) | n/a | `string` | n/a | yes |
| <a name="input_scale_in_rule"></a> [scale\_in\_rule](#input\_scale\_in\_rule) | n/a | `string` | n/a | yes |
| <a name="input_scale_set_name"></a> [scale\_set\_name](#input\_scale\_set\_name) | n/a | `string` | n/a | yes |
| <a name="input_spot_restore_enabled"></a> [spot\_restore\_enabled](#input\_spot\_restore\_enabled) | n/a | `string` | n/a | yes |
| <a name="input_spot_restore_timeout"></a> [spot\_restore\_timeout](#input\_spot\_restore\_timeout) | n/a | `string` | n/a | yes |
| <a name="input_storage_account_url"></a> [storage\_account\_url](#input\_storage\_account\_url) | n/a | `string` | n/a | yes |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | n/a | `list(string)` | n/a | yes |
| <a name="input_ultra_ssd_enabled"></a> [ultra\_ssd\_enabled](#input\_ultra\_ssd\_enabled) | n/a | `string` | n/a | yes |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | n/a | `string` | n/a | yes |
| <a name="input_vm_data_disk_caching"></a> [vm\_data\_disk\_caching](#input\_vm\_data\_disk\_caching) | n/a | `string` | n/a | yes |
| <a name="input_vm_data_disk_create_option"></a> [vm\_data\_disk\_create\_option](#input\_vm\_data\_disk\_create\_option) | n/a | `string` | n/a | yes |
| <a name="input_vm_data_disk_size_gb"></a> [vm\_data\_disk\_size\_gb](#input\_vm\_data\_disk\_size\_gb) | n/a | `string` | n/a | yes |
| <a name="input_vm_data_disk_write_accelerator_enabled"></a> [vm\_data\_disk\_write\_accelerator\_enabled](#input\_vm\_data\_disk\_write\_accelerator\_enabled) | n/a | `string` | n/a | yes |
| <a name="input_vm_data_storage_account_type"></a> [vm\_data\_storage\_account\_type](#input\_vm\_data\_storage\_account\_type) | n/a | `string` | n/a | yes |
| <a name="input_vm_instances"></a> [vm\_instances](#input\_vm\_instances) | n/a | `string` | n/a | yes |
| <a name="input_vm_name_prefix"></a> [vm\_name\_prefix](#input\_vm\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_vm_net_iface_ipconfig_name"></a> [vm\_net\_iface\_ipconfig\_name](#input\_vm\_net\_iface\_ipconfig\_name) | n/a | `string` | n/a | yes |
| <a name="input_vm_net_iface_name"></a> [vm\_net\_iface\_name](#input\_vm\_net\_iface\_name) | n/a | `string` | n/a | yes |
| <a name="input_vm_net_iface_private_ip_address_allocation"></a> [vm\_net\_iface\_private\_ip\_address\_allocation](#input\_vm\_net\_iface\_private\_ip\_address\_allocation) | n/a | `string` | n/a | yes |
| <a name="input_vm_network_interface"></a> [vm\_network\_interface](#input\_vm\_network\_interface) | n/a | `string` | n/a | yes |
| <a name="input_vm_os_disk_caching"></a> [vm\_os\_disk\_caching](#input\_vm\_os\_disk\_caching) | n/a | `string` | n/a | yes |
| <a name="input_vm_os_disk_size_gb"></a> [vm\_os\_disk\_size\_gb](#input\_vm\_os\_disk\_size\_gb) | n/a | `string` | n/a | yes |
| <a name="input_vm_os_disk_write_accelerator_enabled"></a> [vm\_os\_disk\_write\_accelerator\_enabled](#input\_vm\_os\_disk\_write\_accelerator\_enabled) | n/a | `string` | n/a | yes |
| <a name="input_vm_os_storage_account_type"></a> [vm\_os\_storage\_account\_type](#input\_vm\_os\_storage\_account\_type) | n/a | `string` | n/a | yes |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | n/a | `string` | n/a | yes |
| <a name="input_vm_source_image_offer"></a> [vm\_source\_image\_offer](#input\_vm\_source\_image\_offer) | n/a | `string` | n/a | yes |
| <a name="input_vm_source_image_publisher"></a> [vm\_source\_image\_publisher](#input\_vm\_source\_image\_publisher) | n/a | `string` | n/a | yes |
| <a name="input_vm_source_image_sku"></a> [vm\_source\_image\_sku](#input\_vm\_source\_image\_sku) | n/a | `string` | n/a | yes |
| <a name="input_vm_source_image_verson"></a> [vm\_source\_image\_verson](#input\_vm\_source\_image\_verson) | n/a | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_vnet_subnet_name"></a> [vnet\_subnet\_name](#input\_vnet\_subnet\_name) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
