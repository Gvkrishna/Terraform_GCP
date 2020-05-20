# Terraform configuration goes here
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

// Terraform plugin for creating random ids
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

########################compute-vm###################
resource "google_compute_instance" "vm" {
  name         = "${var.compute}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["compute", "vm"]

  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
  metadata = {
    compute = "vm"
  }
  metadata_startup_script = "( echo ${var.compute} >> /info.txt; echo ${var.bigtable} >> /info.txt; echo ${var.dataproc} >> /info.txt )"
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
  
####################################################################################
# Dataproc Cluster
####################################################################################
# Build Nodes
resource "google_dataproc_cluster" "mydataproc" {
  name     = "${var.dataproc}"
  region   = var.region
  labels = {
    dataproc = "cluster"
  }

  cluster_config {
    autoscaling_config {
      policy_uri = google_dataproc_autoscaling_policy.asp.name
    }
    #staging_bucket = var.staging_bucket

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
    # Override or set some custom properties
    software_config {
      image_version = var.image_version
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }
    gce_cluster_config {
      tags = ["dataproc", "cluster"]
      service_account_scopes = [
        "https://www.googleapis.com/auth/monitoring",
        "useraccounts-ro",
        "storage-rw",
        "logging-write",
      ]
      #network    = google_compute_network.dataproc_network.name
      #service_account = var.service_account #optional if you want to choose a service account
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh"
      timeout_sec = 500
    }
  }
}

#################################################################################################
									#Bigtable
#################################################################################################

resource "google_bigtable_instance" "development-instance" {
  name          = "${var.bigtable}"
  instance_type = "DEVELOPMENT"

  cluster {
    cluster_id   = "bigtable-cluste"
    zone         = var.zone
    storage_type = "HDD"
  }
}

#################################################################################################
#									dataproc autoscaling
##################################################################################################


resource "google_dataproc_autoscaling_policy" "asp" {
  policy_id = "dataproc-policy"
  location  = "${var.region}"

  worker_config {
    max_instances = 4
  }
  basic_algorithm {
    cooldown_period = "120s"
    yarn_config {
      graceful_decommission_timeout = "30s"

      scale_up_factor   = 1
      scale_down_factor = 1
    }
  }
}
# Submit an example spark job to a dataproc cluster
resource "google_dataproc_job" "spark" {
  region       = google_dataproc_cluster.mydataproc.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mydataproc.name
  }

  spark_config {
    main_class    = "org.apache.spark.examples.SparkPi"
    jar_file_uris = ["file:///usr/lib/spark/examples/jars/spark-examples.jar"]
    args          = ["10000"]

    properties = {
      "spark.logConf" = "true"
      "spark.executor.memory" = "2600m"
    }

    logging_config {
      driver_log_levels = {
        "root" = "INFO"
      }
    }
  }
}

# Submit an example pyspark job to a dataproc cluster
resource "google_dataproc_job" "pyspark" {
  region       = google_dataproc_cluster.mydataproc.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mydataproc.name
  }

  pyspark_config {
    main_python_file_uri = "gs://dataproc-examples-2f10d78d114f6aaec76462e3c310f31f/src/pyspark/hello-world/hello-world.py"
    properties = {
      "spark.logConf" = "true"
      "spark.executor.memory" = "2800m"
    }
  }
}
resource "google_dataproc_job" "pig" {
  region       = google_dataproc_cluster.mydataproc.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mydataproc.name
  }
  pig_config {
    query_list = [
      "LNS = LOAD 'file:///usr/lib/pig/LICENSE.txt ' AS (line)",
      "WORDS = FOREACH LNS GENERATE FLATTEN(TOKENIZE(line)) AS word",
      "GROUPS = GROUP WORDS BY word",
      "WORD_COUNTS = FOREACH GROUPS GENERATE group, COUNT(WORDS)",
      "DUMP WORD_COUNTS",
    ]
  }
}
resource "google_dataproc_job" "sparksql" {
  region       = google_dataproc_cluster.mydataproc.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mydataproc.name
  }
  sparksql_config {
    query_list = [
      "DROP TABLE IF EXISTS dprocjob_test",
      "CREATE TABLE dprocjob_test(bar int)",
      "SELECT * FROM dprocjob_test WHERE bar > 2",
    ]
  }
}