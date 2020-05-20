
#Enter your project ID
project = "dataproc-274104"

#Enter your region
region = "us-central1"

#Enter you machine type
machine_types = {
  "master" = "n1-standard-1"
  "worker" = "n1-standard-1"
}
#Enter required cluster nodes
count_server = {
  "worker" = "2"
  "master" = "1"
  "preemptible" = "1"
}
service_account = " "
