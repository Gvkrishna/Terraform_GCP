// Configure the Google Cloud provider
provider "google" {
 #credentials = file("dataproc-274104-7e8c2490f1db.json")
 project     = "dataproc-274104"
 region      = "us-west1"
}
// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "flask-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-west1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask; sudo wget https://ftp.postgresql.org/pub/source/v12.0/postgresql-12.0.tar.gz"
 metadata = {
   ssh-keys = "krishnag:${file("~/.ssh/id_rsa.pub")}"
 }
 provisioner "file" {
    source      = "/c/Users/krishnag/.ssh/id_rsa.pub"
    destination = "/etc/"

    connection {
      host        = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      port        = "22"
      user        = "krishnag"
      private_key = "${file("~/.ssh/id_rsa")}"
      agent       = false
    }
  }
 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

// A variable for extracting the external ip of the instance
#output "ip" {
# value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
#}
