terraform {
  required_providers {
    azurerm = {
      version = "=3.0.0"
      source  = "hashicorp/azurerm"
    }
  }
  backend "local" {
    path = "files/raimidevtest.tfstate"
  }
}

variable "clientId" {
  type        = string
  description = "the client Id"
}

variable "clientSecret" {
  type        = string
  description = "the client secret"
}

variable "subscription" {
  type        = string
  description = "the client secret"
}

variable "tenantId" {
  type        = string
  description = "the tenanntId"
}

variable "customimagename" {
  type        = string
  description = "the customimagename"
}

variable "rgname" {
  type        = string
  description = "the resource group name"
}

variable "packermanifestoutputname" {
  type    = string
  default = "packer-manifest.json"
}



provider "azurerm" {
  client_id                  = var.clientId
  client_secret              = var.clientSecret
  subscription_id            = var.subscription
  tenant_id                  = var.tenantId
  skip_provider_registration = true
  features {

  }
}

locals {
  resourcelocation = "eastus"
}

# data "azurerm_image" "ubuntubuildone" {
#   name                = var.customimagename
#   resource_group_name = var.rgname
# }

data "external" "packerimagebuild" {
  program = ["bash", "${path.module}/scripts/gt_image_name.sh", "files/${var.packermanifestoutputname}", var.customimagename, var.subscription, var.rgname]
  # query = {
  #   filename         = "files/${var.packermanifestoutputname}"
  #   managedimagename = var.customimagename
  #   subId            = var.subscription
  #   rgName           = var.rgname
  # }

}

resource "random_string" "networkname" {
  length = 10
}


resource "azurerm_virtual_network" "vnet" {
  resource_group_name = var.rgname
  name                = random_string.networkname.result
  address_space       = ["10.0.1.0/16"]
  location            = "eastus"

}

resource "azurerm_subnet" "vsubnet" {
  name                 = "${random_string.networkname.result}subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rgname
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vnetinterface" {
  name                = "${random_string.networkname.result}vnetinterface"
  depends_on          = [azurerm_virtual_network.vnet]
  resource_group_name = var.rgname
  location            = local.resourcelocation

  ip_configuration {
    name                          = "${random_string.networkname.result}ip"
    subnet_id                     = azurerm_subnet.vsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_image" "managedimagename" {
  name                = trim(data.external.packerimagebuild.result.imagename, "\"\\")
  resource_group_name = var.rgname
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = "${random_string.networkname.result}linuxvm"
  resource_group_name   = var.rgname
  location              = local.resourcelocation
  network_interface_ids = [azurerm_network_interface.vnetinterface.id]
  admin_username        = "olatunde"
  size                  = "Standard_DS1_v2"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.managedimagename.id
}

# data "archive_file" "archivefoldercontent" {
#   type        = "zip"
#   source_dir  = "${path.module}/files/"
#   output_path = "${path.module}/contents.zip"
# }

# data "azurerm_resource_group" "packerbuildlab" {
#   name = var.rgname
# }

# data "azurerm_storage_account" "packerbuildrg" {
#   resource_group_name = data.azurerm_resource_group.packerbuildlab.name
#   name                = "packrbuildlabstorage"
#   //location = "eastus"
# }

# resource "azurerm_storage_container" "contentzip" {
#   name                  = "terraformdevstatefile"
#   container_access_type = "private"
#   storage_account_name  = data.azurerm_storage_account.packerbuildrg.name
# }

# resource "azurerm_storage_blob" "uploadfilecontent" {
#   source                 = data.archive_file.archivefoldercontent.output_path
#   storage_account_name   = data.azurerm_storage_account.packerbuildrg.name
#   storage_container_name = azurerm_storage_container.contentzip.name
#   name                   = data.archive_file.archivefoldercontent.id
#   type                   = "Block"
# }

# resource "azurerm_log_analytics_workspace" "devlogworkspace" {
#   name = "devclusterworkspace"
#   resource_group_name = "monitoring"
#   location = "eastus"
# }

# import {
#   id ="/subscriptions/1869bf53-59b1-4df5-b50b-9907ccf235b0/resourceGroups/monitoring/providers/Microsoft.OperationalInsights/workspaces/devclusterworkspace"
#   to = azurerm_log_analytics_workspace.devlogworkspace
# }




output "info" {
  #value = data.azurerm_image.ubuntubuildone
  value = data.external.packerimagebuild.result
  #value = azurerm_storage_blob.uploadfilecontent
}


output "vmresult" {
  #value = data.azurerm_image.ubuntubuildone
  value = azurerm_linux_virtual_machine.linuxvm
  sensitive = true
  #value = azurerm_storage_blob.uploadfilecontent
}