provider "google" {
  project     = "dataproc-274104"
  #project     = "postgresql-276510"
  region      = "us-central1"
}
resource "google_dataproc_cluster" "cluster-2" {
  name     = "dataproc-multinode"
  region      = "us-central1"
  #labels = {
  #  cluster = "one-master-two-worker"
 # }
  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-1"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 15
      }
    }
    worker_config {
      num_instances    = 2
      machine_type     = "n1-standard-1"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 15
        num_local_ssds    = 1
      }
    }
    preemptible_worker_config {
      num_instances = 0
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 15
        num_local_ssds    = 0
      }
    }
    software_config {
      image_version = "1.3.7-deb9"
      override_properties = {
        "dataproc:job.history.to-gcs.enabled" = "true"
      }
    }
    gce_cluster_config {
    #  tags = ["cluster", "one-master-two-worker"]
      service_account_scopes = [
        "https://www.googleapis.com/auth/monitoring",
        "useraccounts-ro",
        "storage-rw",
        "logging-write",
      ]
    }
  }
}
