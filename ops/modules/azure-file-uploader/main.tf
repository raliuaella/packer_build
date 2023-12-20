terraform {
  required_providers {
    azurerm = {
      version = "=3.0.0"
      source  = "hashicorp/azurerm"
    }
  }
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

data "archive_file" "archivefoldercontent" {
  type        = "zip"
  source_dir  = "${var.pathtodirtoupload}"
  output_path = "${path.module}/archivefoldercontent.zip"
}

data "azurerm_storage_account" "storageaccountname" {
  resource_group_name = var.rgname
  name                = var.storageaccountname
}

data "azurerm_storage_container" "contentzip" {
  name                  = var.storagecontainername
  storage_account_name  = data.azurerm_storage_account.storageaccountname.name
}

resource "azurerm_storage_blob" "uploadfilecontent" {
  source                 = var.archivefirst == true ? data.archive_file.archivefoldercontent.output_path: var.pathtodirtoupload
  storage_account_name   = data.azurerm_storage_account.storageaccountname.name
  storage_container_name = data.azurerm_storage_container.contentzip.name
  name                   = data.archive_file.archivefoldercontent.id
  type                   = "Block"

}



