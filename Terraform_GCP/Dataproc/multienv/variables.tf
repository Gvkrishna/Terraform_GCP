variable "project" { 
 }
variable "location" {
  type = string
  default = "US"
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-a"
}

variable "cidrs" { default = [] }

variable "environment" {
  type = string
  default = "master"
}

variable "machine_types" {
  default = {
    "worker" = "n1-standard-2"
    "master" = "n1-standard-2"
    "preemptible" = "n1-standard-2"
  }
}

variable "disk_type" {
  default = {
    "worker" = "pd-standard"
    "master" = "pd-standard"
    "preemptible" = "pd-standard"
  }
}

variable "disk_image" {
   type = string
   default = "debian-cloud/debian-9"
 }

variable "disk_size" {
  default = {
    "worker" = 15
    "master" = 15
  }
}

variable "count_server" {
  default = {
    "worker" = 0
    "master" = 1
    "preemptible" = 0
  }
}
variable "sql_tier" {
  type = string
  default = "db-n1-standard-1"
}

variable "service_account" {
  type = string
}

variable "image_version" {
  type = string
  default = "1.4-debian9"
}
