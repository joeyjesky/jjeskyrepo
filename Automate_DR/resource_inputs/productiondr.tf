
module "app_pattern" {
    source                = "./terraform_standard_application_module"
    environment           = "${var.environment}"
    location              = "${var.location}"
    division              = "${var.business_unit}"
    cost_center           = "${var.cost_center}"
    requestor             = "${var.requestor}"
    confidentiality_input = "${var.confidentiality}"
    accessibility_input   = "${var.accessibility}"
    criticality_input     = "${var.criticality}"
    appid                 = "${var.appid}"
    audit_input           = "${var.audit}"
    expiration_date       = "${var.expiration_date}"
    virtual_network       = "${var.virtual_network}"
    virtual_network_rg    = "${var.virtual_network_rg}"
    subnet_prefix         = "${var.subnet_prefix}"
    resource_group_name   = "${module.app_rg.concatenated_name}"
    subnet_name           = "${module.app_sn.concatenated_name}"
    nsg_name              = "${module.app_nsg.concatenated_name}"
    recovery_vault_name   = "ABV-MER-APP2781-P-EUS03"
    storage_account_name  = "${module.app_sa.lower_name_rand}"
    sub_id                = "${var.azure_sub_id}"
    rt_id                 = "${var.rt_id}"
}
resource "azurerm_recovery_services_fabric" "primary" {
  name                = "primary-fabric"
  resource_group_name = "${module.app_pattern.rg_name}"
  recovery_vault_name = "${module.app_pattern.rsv_name}"
  location            = "centralus"
}

resource "azurerm_recovery_services_fabric" "secondary" {
  name                = "secondary-fabric"
  resource_group_name = "${module.app_pattern.rg_name}"
  recovery_vault_name = "${module.app_pattern.rsv_name}"
  location            = "${var.location}"
}

resource "azurerm_recovery_services_protection_container" "primary" {
  name                 = "primary-protection-container"
  resource_group_name  = "${module.app_pattern.rg_name}"
  recovery_vault_name  = "${module.app_pattern.rsv_name}"
  recovery_fabric_name = "${azurerm_recovery_services_fabric.primary.name}"
}

resource "azurerm_recovery_services_protection_container" "secondary" {
  name                 = "secondary-protection-container"
  resource_group_name  = "${module.app_pattern.rg_name}"
  recovery_vault_name  = "${module.app_pattern.rsv_name}"
  recovery_fabric_name = "${azurerm_recovery_services_fabric.secondary.name}"
}

resource "azurerm_recovery_services_replication_policy" "policy" {
  name                                                 = "policyJJ"
  resource_group_name                                  = "${module.app_pattern.rg_name}"
  recovery_vault_name                                  = "${module.app_pattern.rsv_name}"
  recovery_point_retention_in_minutes                  = "${24 * 60}"
  application_consistent_snapshot_frequency_in_minutes = "${1 * 60}"
}

resource "azurerm_recovery_services_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = "${module.app_pattern.rg_name}"
  recovery_vault_name                       = "${module.app_pattern.rsv_name}"
  recovery_fabric_name                      = "${azurerm_recovery_services_fabric.primary.name}"
  recovery_source_protection_container_name = "${azurerm_recovery_services_protection_container.primary.name}"
  recovery_target_protection_container_id   = "${azurerm_recovery_services_protection_container.secondary.id}"
  recovery_replication_policy_id            = "${azurerm_recovery_services_replication_policy.policy.id}"
}

resource "azurerm_recovery_replicated_vm" "vm-replication" {
  name                                      = "MMFDLNPP01"
  resource_group_name                       = "${module.app_pattern.rg_name}"
  recovery_vault_name                       = "${module.app_pattern.rsv_name}"
  source_recovery_fabric_name               = "${azurerm_recovery_services_fabric.primary.name}"
  source_vm_id                              = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/rg-mer-app2781-p-cus01/providers/Microsoft.Compute/virtualMachines/MMFDLNPP01"
  recovery_replication_policy_id            = "${azurerm_recovery_services_replication_policy.policy.id}"
  source_recovery_protection_container_name = "${azurerm_recovery_services_protection_container.primary.name}"

  target_resource_group_id                = "${module.app_pattern.rg_id}"
  target_recovery_fabric_id               = "${azurerm_recovery_services_fabric.secondary.id}"
  target_recovery_protection_container_id = "${azurerm_recovery_services_protection_container.secondary.id}"

  managed_disk {
    disk_id                    = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourcegroups/rg-mer-app2781-p-cus01/providers/Microsoft.Compute/disks/PHYSICALDRIVE0-MMFDLNPP01"
    staging_storage_account_id = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-EUS02/providers/Microsoft.Storage/storageAccounts/saapp2781cusdr"
    target_resource_group_id   = "${module.app_pattern.rg_id}"
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }
    managed_disk {
    disk_id                    = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourcegroups/rg-mer-app2781-p-cus01/providers/Microsoft.Compute/disks/PHYSICALDRIVE1-MMFDLNPP01"
    staging_storage_account_id = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-EUS02/providers/Microsoft.Storage/storageAccounts/saapp2781cusdr"
    target_resource_group_id   = "${module.app_pattern.rg_id}"
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }
}

resource "azurerm_recovery_replicated_vm" "vm-replication2" {
  name                                      = "VWMERPNTSQL01P"
  resource_group_name                       = "${module.app_pattern.rg_name}"
  recovery_vault_name                       = "${module.app_pattern.rsv_name}"
  source_recovery_fabric_name               = "${azurerm_recovery_services_fabric.primary.name}"
  source_vm_id                              = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-CUS01/providers/Microsoft.Compute/virtualMachines/VWMERPNTSQL01P"
  recovery_replication_policy_id            = "${azurerm_recovery_services_replication_policy.policy.id}"
  source_recovery_protection_container_name = "${azurerm_recovery_services_protection_container.primary.name}"

  target_resource_group_id                = "${module.app_pattern.rg_id}"
  target_recovery_fabric_id               = "${azurerm_recovery_services_fabric.secondary.id}"
  target_recovery_protection_container_id = "${azurerm_recovery_services_protection_container.secondary.id}"

  managed_disk {
    disk_id                    = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-CUS01/providers/Microsoft.Compute/disks/DSK-MER-VWMERPNTSQL01-P-CUS01"
    staging_storage_account_id = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-EUS02/providers/Microsoft.Storage/storageAccounts/saapp2781cusdr"
    target_resource_group_id   = "${module.app_pattern.rg_id}"
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }
    managed_disk {
    disk_id                    = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-CUS01/providers/Microsoft.Compute/disks/DSK-MER-VWMERPNTSQLDATA01-P-CUS01"
    staging_storage_account_id = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-EUS02/providers/Microsoft.Storage/storageAccounts/saapp2781cusdr"
    target_resource_group_id   = "${module.app_pattern.rg_id}"
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }
    managed_disk {
    disk_id                    = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-CUS01/providers/Microsoft.Compute/disks/DSK-MER-VWMERPNTSQLTEMPDATA01-P-CUS01"
    staging_storage_account_id = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-EUS02/providers/Microsoft.Storage/storageAccounts/saapp2781cusdr"
    target_resource_group_id   = "${module.app_pattern.rg_id}"
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }
}


#Cache storage must be in same location as VM's being replicated
