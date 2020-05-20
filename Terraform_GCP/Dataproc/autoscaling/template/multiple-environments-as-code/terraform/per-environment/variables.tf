variable "ibmcloud_api_key" {}

variable "environment_name" {}

variable "space_managers" {
  type    = "list"
  default = []
}

variable "space_auditors" {
  type    = "list"
  default = []
}

variable "space_developers" {
  type    = "list"
  default = []
}

variable "cluster_datacenter" {}

variable "cluster_public_vlan_id" {}

variable "cluster_private_vlan_id" {}

variable "cluster_machine_type" {}

variable "worker_num" {}

variable "cluster_hardware" {}

variable "cloudantnosqldb_plan" {}

variable "cloudantnosqldb_location" {}

variable "cloudobjectstorage_plan" {}

variable "cloudobjectstorage_location" {}

variable "logdna_plan" {}

variable "logdna_location" {}

variable "sysdig_plan" {}

variable "sysdig_location" {}