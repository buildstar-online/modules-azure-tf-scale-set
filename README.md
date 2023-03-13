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

- The terraform documentation for `azurerm_linux_virtual_machine_scale_set` can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).
