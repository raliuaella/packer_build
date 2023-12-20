packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"

    }
  }
}

variable ImagePub {
  type    = string
  default = "Canonical"
}

variable rg {
  type    = string
  default = "packerbuildlab"
}

variable subscription {
  type    = string
 default = "1869bf53-59b1-4df5-b50b-9907ccf235b0"
}

variable clientId {
  type = string
}


variable clientSecret {
  type        = string
  description = "set the value of the client secret file"
}


source "azure-arm" "centos-ndeojs-angular-buoild" {
  subscription_id = "${var.subscription}"
  client_id       = var.clientId
  client_secret   = var.clientSecret

  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  #location                          = "East US"
  image_sku          = "18_04-lts-gen2"
  managed_image_name = "ubuntusrverbuildone"
  #storage_account                   = "packrbuildlabstorage"
  managed_image_resource_group_name = "${var.rg}"
  #resource_group_name       = "${var.rg}"
  os_type                   = "Linux"
  vm_size                   = "Standard_DS2_v2"
  build_resource_group_name = "${var.rg}"
  ssh_username              = "ubuntu"

  #   shared_image_gallery_destination {
  #     subscription         = "${var.subscription}"
  #     resource_group       = "${var.rg}"
  #     gallery_name         = "pihemisostore"
  #     image_name           = "ubuntupihembuildone"
  #     image_version        = "1.0.0"
  #     replication_regions  = ["eastus", "westus"]
  #     storage_account_type = "Standard_LRS"
  #   }
}

build {
  sources = ["sources.azure-arm.centos-ndeojs-angular-buoild"]

  provisioner "shell" {
    inline = ["sudo apt-get -y update", "sudo apt-get upgrade -y"]
  }

  provisioner "shell" {
    script = "scripts/az-aws-install.sh"
    pause_before = "10s"
  }


  post-processor "manifest" {}
  post-processor "compress" {
    output = "packer_{{.BuildName }}-image.zip"
  }

}