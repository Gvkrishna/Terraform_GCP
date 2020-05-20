# Configure the Google Cloud provider
provider "google" {
 #credentials = "${file("postgresql-276510-a600221de4d9.json")}"
 project     = "postgresql-276510"
 region      = "us-central1"
}


# Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// Enable googleapis
resource "google_project_service" "compute_api" {
  project = "postgresql-276510"
  service = "compute.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "oslogin_api" {
  project = "postgresql-276510"
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "iam_api" {
  project = "postgresql-276510"
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


# A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
	name         = "postgresvm-${random_id.instance_id.hex}"
	machine_type = "n1-standard-1"
	zone         = "us-central1-c"

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
		ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
	}

	depends_on = ["google_compute_firewall.firewall-externalssh"]
	connection {
		type = "ssh"
		user = "ubuntu"
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
                "bash -x /tmp/postgres_script.sh"
		]
	}
}
