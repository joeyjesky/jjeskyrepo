variable "environment" {
  type        = "string"
  description = "Pipeline variable for defining Terraform working subscription and naming conventions"
}
variable "business_unit" {
  type        = "string"
  description = "Business unit name as mapped under the naming module"
}
variable "cost_center" {
  type        = "string"
  description = "Freehand definition for cost center"
}
variable "requestor" {
    type        = "string"
    description = "Name of the individual who requested the resource"
}
variable "confidentiality" {
    type        = "string"
    description = "Parent input for confidentiality tag"
}
variable "accessibility" {
    type        = "string"
    description = "Parent input for accessibility tag"
}
variable "criticality" {
    type        = "string"
    description = "Parent input for criticality tag"
}
variable "appid" {
    type        = "string"
    description = "Application ID tag"
}
variable "audit" {
    type = "string"
    description = "Parent input for audit tag"
}
variable "expiration_date" {
    type        = "string"
    description = "The anticipated date for removal of this resource, or none"
}
variable "location" {
  type        = "string"
  description = "Azure datacenter location for resources"
}
variable "virtual_network" {
  type        = "string"
  description = "Environment specific name of virtual network to attach resources"
}
variable "virtual_network_rg" {
    type        = "string"
    description = "Name of the vnet resource group for subnet to drop into"
}
variable "subnet_prefix" {
    type        = "string"
    description = "Environment specific subnet prefix for application"
}
variable "workload" {
    type        = "string"
    description = "Freehand description of workload for resource naming"
}
variable "rt_id" {
    type        = "string"
    description = "Name of route table for attachment to subnet"
}

variable "azure_sub_id" {
  description = "Azure subscription ID"
}

variable "azure_client_id" {
  description = "Azure SP user ID"
}

variable "azure_client_secret" {
  description = "Azure SP user secret"
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
}
variable "privateIPAddressStart01" {
    type = "string"
    default = ""
}

variable "vmEnv" {
    type = "string"
    default = "N"
}
variable "vmName01" {
    type = "string"
    default = ""
}

variable "oms_rg" {
    type = "string"
    description = "OMS Workspace Resource Group"
}

variable "oms_id" {
    type = "string"
    description = "OMS Workspace"
}
variable "countInt" {
    type = "string"
    default = 1
}

variable "virtualMachineSize" {
    type = "string"
    default = "Standard_DS3_v2"
}
variable "sqlpublisher" {
    type = "string"
    default = ""
}
variable "sqlversion" {
    type = "string"
    default = ""
}
variable "sqloffer" {
    type = "string"
    default = ""
}
variable "sqlsku" {
    type = "string"
    default = ""
}
