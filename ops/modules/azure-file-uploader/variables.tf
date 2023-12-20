
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

variable "pathtodirtoupload" {
  type        = string
  description = "the directory of file to upload"
}

variable "archivefirst" {
  type        = bool
  description = "whether to zip it first"
  default = false
}

variable "rgname" {
  type        = string
  description = "the resource group name"
}

variable "storageaccountname" {
  type        = string
  description = "the name of the storage account"
}

variable "storagecontainername" {
  type        = string
  description = "the name of the storage account"
}


variable "createcontainerifnotexist" {
  type        = bool
  description = "whether to create container if not exist"
  default = false
}