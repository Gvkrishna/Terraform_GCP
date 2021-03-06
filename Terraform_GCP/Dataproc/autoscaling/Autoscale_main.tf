
provider "google" {
  project     = "dataproc-274104"
  region      = "us-central1"
}
resource "google_dataproc_cluster" "cluster_policy" {
  name     = "dataproc-policy"
  region   = "us-central1"

  cluster_config {
    autoscaling_config {
      policy_uri = google_dataproc_autoscaling_policy.asp.name
    }
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
      }
    }
    software_config {
      image_version = "1.3.7-deb9"
    }
    gce_cluster_config {
      tags = ["cluster", "autoscaling"]
      service_account_scopes = [
        "https://www.googleapis.com/auth/monitoring",
        "useraccounts-ro",
        "storage-rw",
        "logging-write",
      ]
    }
  }
}
resource "google_dataproc_autoscaling_policy" "asp" {
  policy_id = "dataproc-policy"
  location  = "us-central1"

  worker_config {
    max_instances = 4
  }

  basic_algorithm {
    yarn_config {
      graceful_decommission_timeout = "60s"

      scale_up_factor   = 0.5
      scale_down_factor = 0.5
    }
  }
}
