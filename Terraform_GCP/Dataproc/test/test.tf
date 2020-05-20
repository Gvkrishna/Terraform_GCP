resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = "dataproce-singlenode"
  region = "global"
  }
  cluster_config {
    staging_bucket = "{}"
    description = "GCS Staging bucket for dataproc."
    #gce_cluster_config {
    #subnetwork       = "default"
    #tags             = "${var.tags}"
    #service_account  = "Dataproc"
    #internal_ip_only = "true"
    #zone             = "europe-west3-a"
    }
    master_config {
      num_instances = "1"
      machine_type  = "n1-standard-4"

      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = "15"
      }
       accelerators = []
    }
    preemptible_worker_config {
      num_instances = 0
    }
    software_config {
      image_version = "1.3-deb9"
      properties = "{}"
      optional_components  = "[]"
    }
    endpoint_config {
      http_ports = {}
      enable_http_port_access = "true"
    }
    gce_cluster_config {
    subnetwork        = "default"
    #tags             = "${var.tags}"
    service_account   = "Dataproc"
    #internal_ip_only = "true"
    zone              = "europe-west3-a"
    }
  }
}