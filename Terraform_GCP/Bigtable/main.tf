
provider "google" {
  credentials = file("terraform-bigtable-1-6b18d07c57c3.json")
  project     = "terraform-bigtable-1"
  region      = "us-central1"
}

resource "google_bigtable_instance" "development-instance" {
  name          = "bigtable"
  instance_type = "DEVELOPMENT"

  cluster {
    cluster_id   = "bigtable-cluster"
    zone         = "us-central1-b"
    storage_type = "HDD"
  }
}
  #network_interface {
   #network = "default"

   #access_config {
    # // Include this section to give the VM an external ip address
   #}
 #}
  #metadata.startup_script = "git clone https://github.com/GoogleCloudPlatform/cloud-bigtable-examples.git; ls; pwd; cd cloud-bigtable-examples/quickstart;  ls; pwd; ./quickstart.sh"
  #provisioner "file" {
   # source      = "files/script.sh"
  # destination  = "/tmp/script.sh"
 #}
  #provisioner "remote-exec" {
    #inline = [
     # "chmod +x /tmp/script.sh",
    # "/tmp/script.sh",
   # ]
  #}
  #// change permissions to executable and pipe its output into a new file
  #provisioner "remote-exec" {
  #   inline = [
  #    "echo project = terraform-bigtable-1 > ~/.cbtrc",
  #    "echo instance = bigtable >> ~/.cbtrc",
  #    "cbt createtable rao",
  #    "cbt ls"
   # ]
  #}


