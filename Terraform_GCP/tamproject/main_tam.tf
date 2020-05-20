# Configure the Google Cloud provider
provider "google" {
 credentials = "${file("postgresql-276510-a600221de4d9.json")}"
 #project     = "postgresql-276510"
 project     = "tamr-270112"
 region      = "var.region"
 zone        = "us-central1-a"
}

# Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// Enable googleapis
resource "google_project_service" "compute_api" {
  #project = "postgresql-276510"
  project     = "tamr-270112"
  service = "compute.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "oslogin_api" {
  #project = "postgresql-276510"
  project     = "tamr-270112"
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "iam_api" {
  #project = "postgresql-276510"
  project     = "tamr-270112"
  service = "iam.googleapis.com"
  disable_on_destroy = false
}
resource "google_compute_firewall" "firewall-externalssh" {
  name    = "firewall-externalssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["externalssh"]
}

##################BUCKET#####################
resource "google_storage_bucket" "REGIONAL" {
  name     = "tamrtask"
  storage_class = "STANDARD"
  location = "us-central1"
}


###############COMPUTEVM#######
# A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
	name         = "tamrtaskvm"
	machine_type = "n1-standard-8"
	zone         = "us-central1-a"
	boot_disk {
		initialize_params {
			image = "gce-uefi-images/ubuntu-1804-lts"
		}
	}
	# Use an existing disk resource
	scratch_disk {
		// Instance Templates reference disks by name, not self link
		interface = "NVME"
	}
	#metadata_startup_script = "${file("startup.sh")}"
	network_interface {
		network = "default"
		access_config {
				# Include this section to give the VM an external ip address
		}
	}
	metadata = {
		ssh-keys = "tamr:${file("~/.ssh/id_rsa.pub")}"
	} 
	depends_on = ["google_compute_firewall.firewall-externalssh"]
	connection {
		type = "ssh"
		user = "tamr"
		host = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
		private_key = "${file("~/.ssh/id_rsa")}"
	}

	provisioner "file" {
		source      = "files/postgres_script.sh"
		destination = "/tmp/postgres_script.sh"
	}
	provisioner "remote-exec" {
		inline = [
                "ls; pwd",
                "sudo chmod +x /tmp/postgres_script.sh",
                #"bash -x /tmp/postgres_script.sh"
		]
	}
}

#################################################################################################
									#Bigtable
#################################################################################################

resource "google_bigtable_instance" "development_instance" {
  name          = "tamrtask-bigtable"
  cluster {
    cluster_id   = "tamrtask-bigtable-cluster"
    zone         = "us-central1-a"
    storage_type = "SSD"
    num_nodes    = 3
  }
}

####################################################################################
# Dataproc Cluster
####################################################################################

resource "google_dataproc_cluster" "tamrtask_dataproc_cluster" {
  name     = "tamrtask-dataproc"
  region      = "us-central1"
  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-highmem-4"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 1000
      }
    }
    worker_config {
      num_instances    = 4
      machine_type     = "n1-standard-16"
      disk_config {
        boot_disk_type    = "pd-ssd"
        boot_disk_size_gb = 100
        num_local_ssds    = 1
      }
    }
    software_config {
      image_version = "1.3.7-deb9"
      override_properties = {
        "dataproc:job.history.to-gcs.enabled" = "true"
      }
    }
    gce_cluster_config {
      service_account_scopes = [
        "https://www.googleapis.com/auth/monitoring",
        "useraccounts-ro",
        "storage-rw",
        "logging-write",
      ]
    }
  }
}

