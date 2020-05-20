# Variable definitions go here
#variable "project" { 
#  default = "postgresql-276510"
#}

variable "location" {
  type = string
  default = "US"
}

variable "region" {
  type = string
  default = "us-central1"
}

#variable "zone" {
#  type = string
#  default = "us-central1-a"
#}

#variable "machine_type" {
#  type = string
# default = "n1-standard-1"
#}

variable "bigtable" {
  type = string
  default = "bigtable-test"
}