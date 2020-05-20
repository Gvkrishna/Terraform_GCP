
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
resource "random_id" "instance_id" {
   byte_length = 8
}

resource "google_project_service" "compute_api" {
  project = var.project
  service = "compute.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "oslogin_api" {
  project = var.project
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "iam_api" {
  project = var.project
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_dataproc_cluster" "mydataproc" {
  name     = "dataproc-cluster-${random_id.instance_id.hex}"
  region   = var.region
  labels = {
    foo = "bar"
  }

  cluster_config {

    master_config {
      num_instances = var.count_server["master"]
      machine_type  = var.machine_types["master"]
      disk_config {
        boot_disk_type    = var.disk_type["master"]
        boot_disk_size_gb = var.disk_size["master"]
      }
    }

    worker_config {
      num_instances    = var.count_server["worker"]
      machine_type     = var.machine_types["worker"]
      disk_config {
        boot_disk_type    = var.disk_type["worker"]
        boot_disk_size_gb = var.disk_size["worker"]
      }
    }

    preemptible_worker_config {
      num_instances = var.count_server["preemptible"]
    }

    software_config {
      image_version = var.image_version
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }

    gce_cluster_config {
      tags = ["foo", "bar"]
      service_account_scopes = [
        "https://www.googleapis.com/auth/monitoring",
        "useraccounts-ro",
        "storage-rw",
        "logging-write",
      ]
    }

    initialization_action {
      script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh"
      timeout_sec = 500
    }
  }
}

