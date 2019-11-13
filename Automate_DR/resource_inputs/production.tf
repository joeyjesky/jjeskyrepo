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
    recovery_vault_name   = "${module.app_rsv.concatenated_name}"
    storage_account_name  = "${module.app_sa.lower_name_rand}"
    sub_id                = "${var.azure_sub_id}"
    rt_id                 = "${var.rt_id}"
}
#Shared SQL VM
module "app_ipconfig01" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "ip_config"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.vmName01}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}
module "app_nic01" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "network_interface"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.vmName01}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}
module "app_vmdisk01" {
    source                    = "./terraform_naming_module"
    resource_type_input       = "disk"
    business_unit_input       = "${var.business_unit}"
    workload                  = "${var.vmName01}"
    environment_input         = "${var.environment}"
    location_descriptor_input = "${var.location}"
}

module "virtual_machines" {
    source                       = "./terraform_sqlvm_azure_module"
    azLocation                   = "${var.location}"
    countInt                     = "${var.countInt}"
    ipConfigurationPrependName   = "${module.app_ipconfig01.loop_prepend}"
    ipConfigurationAppendName    = "${module.app_ipconfig01.loop_append}"
    nicPrependName               = "${module.app_nic01.loop_prepend}"
    nicAppendName                = "${module.app_nic01.loop_append}"
    privateIPAddressStart        = "${var.privateIPAddressStart01}"
    rgName                       = "${module.app_pattern.rg_name}"
    subnetId                     = "${module.app_pattern.sn_id}"
    OSProfileComputerPrependName = "${var.vmName01}"
    OSProfileComputerAppendName  = "${var.vmEnv}"
    virtualMachineSize           = "${var.virtualMachineSize}"
    vmDiskPrependName            = "${module.app_vmdisk01.loop_prepend}"
    vmDiskAppendName             = "${module.app_vmdisk01.loop_append}"
    vmPrependName                = "${var.vmName01}"
    vmAppendName                 = "${var.vmEnv}"
    availabilitySetId            = "${azurerm_availability_set.application.id}"
    sa_blob_endpoint             = "${module.app_pattern.sa_blob_endpoint}"
    sa_blob_access_key           = "${module.app_pattern.sa_primary_access_key}"
    WindowsStorageImageReferencePublisher = "${var.sqlpublisher}"
    WindowsStorageImageReferenceOffer = "${var.sqloffer}"
    WindowsStorageImageReferenceSKU = "${var.sqlsku}"
    WindowsStorageImageReferenceVersion = "${var.sqlversion}"
}

resource "azurerm_managed_disk" "MMFDLNPP01disk1" {
    name                            = "PHYSICALDRIVE1-MMFDLNPP01"
    location                        = "centralus"
    resource_group_name             = "rg-mer-app2781-p-cus01"
    storage_account_type            = "StandardSSD_LRS"
    create_option                   = "Restore"
    source_resource_id              = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-MER-APP2781-P-CUS01/providers/Microsoft.Compute/disks/asrseeddisk-MMFDLNPP-PHYSICAL-c1f83965-52d6-408a-b421-9167b2f4e036/bookmark/8522877d-8667-481c-af5e-826e33fb5184"
    disk_size_gb                    = 15
}
resource "azurerm_network_interface" "MMFDLNPP01nic" {
    name                            = "MMFDLNPP019af42ac8-12f4-4d86-90c6-a973e337ba97"
    location                        = "centralus"
    resource_group_name             = "rg-mer-app2781-p-cus01"
    ip_configuration {
      name                          = "ipConfigMMFDLNPP019af42ac8-12f4-4d86-90c6-a973e337ba97"
      subnet_id                     = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/RG-ENT-MAINVNET-P-CUS01/providers/Microsoft.Network/virtualNetworks/VNET-ENT-MAINVNET-P-CUS01/subnets/SN-MER-APP2781-P-CUS01"
      private_ip_address_allocation = "static"
      private_ip_address            = "10.236.17.197"
    }
}
resource "azurerm_virtual_machine" "MMFDLNPP01" {
    name                            = "MMFDLNPP01"
    resource_group_name             = "rg-mer-app2781-p-cus01"
    location                        = "centralus"
    network_interface_ids           = ["/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/rg-mer-app2781-p-cus01/providers/Microsoft.Network/networkInterfaces/MMFDLNPP019af42ac8-12f4-4d86-90c6-a973e337ba97"]
    primary_network_interface_id    = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourceGroups/rg-mer-app2781-p-cus01/providers/Microsoft.Network/networkInterfaces/MMFDLNPP019af42ac8-12f4-4d86-90c6-a973e337ba97"
    vm_size                         = "Standard_DS2_v2"
    boot_diagnostics {
        enabled                     = "true"
        storage_uri                 = "https://samerapp2781pcus01b683.blob.core.windows.net"
    } 
    os_profile_windows_config {}
    storage_os_disk {
        name                        = "PHYSICALDRIVE0-MMFDLNPP01"
        caching                     = "ReadWrite"
        create_option               = "Attach"
        disk_size_gb                = 128
        managed_disk_id             = "/subscriptions/7e2de2c9-54ba-4e34-a048-05e8c41766c0/resourcegroups/rg-mer-app2781-p-cus01/providers/Microsoft.Compute/disks/PHYSICALDRIVE0-MMFDLNPP01"
        managed_disk_type           = "StandardSSD_LRS"
    }
}
