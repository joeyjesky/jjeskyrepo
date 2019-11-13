#Provider config
provider "azurerm" {
    subscription_id = "${var.azure_sub_id}"
    client_id       = "${var.azure_client_id}"
    client_secret   = "${var.azure_client_secret}"
    tenant_id       = "${var.azure_tenant_id}"
}

#Generate name for app resource groups
module "app_rg" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "resource_group"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

#Generate name for app subnet
module "app_sn" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "subnet"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

#Generate name for app NSG
module "app_nsg" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "network_security_group"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

#Generate name for recovery services vault
module "app_rsv" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "recovery_services_vault"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

#Generate name for storage account
module "app_sa" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "storage_account"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

#Call app pattern module using generated names and input variables


module "app_nsr" {
    source              = "./terraform_nsg_rules_azure_module"
    resource_group_name = "${module.app_pattern.rg_name}"
    nsg_name            = "${module.app_pattern.nsg_name}"
    subnet_prefix       = "${var.subnet_prefix}"
}

module "app_as" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "availability_set"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
    naming_index              = "01"
}
resource "azurerm_availability_set" "application" {
  name                = "${module.app_as.concatenated_name}"
  location            = "${var.location}"
  resource_group_name = "${module.app_pattern.rg_name}"
  managed             = "true"
}

module "app_backup" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "backup_policy"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
    naming_index              = "01"
}

module "backup_policy" {
    source                    = "./terraform_backup_policy_module"
    backup_policy_name        = "${module.app_backup.concatenated_name}"
    resource_group_name       = "${module.app_pattern.rg_name}"
    recovery_vault_name       = "${module.app_pattern.rsv_name}"
    environment               = "${var.environment}"
} 
module "app_dag" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "diagnostic_settings"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.workload}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

module "diagnostic_settings" {
    source                    = "./terraform_diagnostic_settings_module"
    dag_name                  = "${module.app_dag.concatenated_name}"
    rsv_id                    = "${module.app_pattern.rsv_id}"
    sub_id                    = "${var.azure_sub_id}"
    oms_rg                    = "${var.oms_rg}"
    oms_id                    = "${var.oms_id}"
} 
