data "template_file" "this" {
  template = file("${var.user_data_path}")

  vars = {
    HOSTNAME               = var.hostname
    USERNAME               = var.username
    GITHUB_USERNAME        = var.github_username
  }
}

resource "random_pet" "vm_name" {
  length    = 2
  separator = "x"
}

resource "random_password" "vm_admin_password" {
  length  = 16
  min_lower = 1
  min_upper = 1
  min_numeric = 1
  special = true
  override_special = "!#&*()-_=+[]{}<>"
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = random_pet.vm_name.id
  value        = random_password.vm_admin_password.result
  content_type = "text/plain"
  key_vault_id = var.keyvault_id
}

resource "azurerm_linux_virtual_machine_scale_set" "scale_set" {
  name                = "${var.environment}-scale-set"
  resource_group_name = var.resource_group
  location            = var.location
  zones               = [ "1", "2", "3" ]
  sku                 = var.vm_sku
  instances           = var.vm_instances
  admin_username      = var.vm_admin_username
  admin_password      = random_password.vm_admin_password.result
  #allow_extension_operations     = false
  disable_password_authentication = false

  # this is the cloud-init data
  custom_data = sensitive(base64encode(data.template_file.this.rendered))

  # Spot bids
  priority        = var.priority == "" ? null : var.priority
  eviction_policy = var.eviction_policy == "" ? null : var.eviction_policy
  max_bid_price   = var.max_bid_price == "" ? null : var.max_bid_price
  overprovision   = var.overprovision == "" ? null : var.overprovision

  dynamic "spot_restore" {
    for_each = var.spot_restore_enabled == null ? [] : [1]
    content {
      enabled    = var.spot_restore_enabled
      timeout    = var.spot_restore_timeout
    }
  }

  additional_capabilities {
    ultra_ssd_enabled = var.ultra_ssd_enabled
  }

  scale_in {
    rule                   = var.scale_in_rule
    force_deletion_enabled = var.scale_in_force_deletion_enabled
  }

  network_interface {
    name                          = var.vm_net_iface_name
    enable_accelerated_networking = false
    enable_ip_forwarding          = true
    network_security_group_id     = azurerm_network_security_group.security_group.id
    primary                       = true

    ip_configuration {
      name      = var.vm_net_iface_ipconfig_name
      primary   = true
      subnet_id = azurerm_subnet.vm_subnet.id

      public_ip_address {
        name = "vmpip"
      }
    }
  }

  os_disk {
    caching                   = var.vm_os_disk_caching
    storage_account_type      = var.vm_os_storage_account_type
    disk_size_gb              = var.vm_os_disk_size_gb
    write_accelerator_enabled = var.vm_os_disk_write_accelerator_enabled
  }

  data_disk {
    caching       = var.vm_data_disk_caching
    create_option = var.vm_data_disk_create_option
    disk_size_gb  = var.vm_data_disk_size_gb
    lun           = "1"
    storage_account_type = var.vm_data_storage_account_type
    write_accelerator_enabled = var.vm_data_disk_write_accelerator_enabled
  }

  
  source_image_reference {
    publisher = var.vm_source_image_publisher
    offer     = var.vm_source_image_offer
    sku       = var.vm_source_image_sku
    version   = var.vm_source_image_verson
  }

  timeouts {
    create = "6m"
    update = "6m"
    delete = "6m"
  }

  boot_diagnostics {
    storage_account_uri = var.storage_account_url
  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.admin_users
  }

  depends_on = [
    data.template_file.this
  ]

}
