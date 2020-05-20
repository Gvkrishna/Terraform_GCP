# yes > /dev/null &
provider "google" {
  project     = "dataproc-274104"
  region      = "us-central1"
}
resource "google_compute_autoscaler" "diskusage" {
  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.diskusage.id

  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 1
    cooldown_period = 15

    cpu_utilization {
      target = 0.7
    }
  }
}

resource "google_compute_instance_template" "diskusage" {
  name           = "my-instance-template"
  machine_type   = "n1-standard-1"
  can_ip_forward = false

  tags = ["foo", "bar"]

  disk {
    source_image = data.google_compute_image.debian_9.self_link
  }

  network_interface {
    network = "default"
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "diskusage" {
  name = "my-target-pool"
}

resource "google_compute_instance_group_manager" "diskusage" {
  name = "my-igm"
  zone = "us-central1-f"

  version {
    instance_template  = google_compute_instance_template.diskusage.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.diskusage.id]
  base_instance_name = "diskusage"
}

data "google_compute_image" "debian_9" {
  family  = "debian-9"
  project = "debian-cloud"
}
