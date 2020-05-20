provider "google" {
  project     = "dataproc-274104"
  region      = "us-central1"
}
resource "google_dataproc_cluster" "mycluster" {
  name   = "dproc-cluster-with-submit-job"
  region = "us-central1"
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
      tags = ["cluster", "one-master-two-worker"]
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
  region       = google_dataproc_cluster.mycluster.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
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
  region       = google_dataproc_cluster.mycluster.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }

  pyspark_config {
    main_python_file_uri = "gs://dataproc-examples-2f10d78d114f6aaec76462e3c310f31f/src/pyspark/hello-world/hello-world.py"
    properties = {
      "spark.logConf" = "true"
    }
  }
}
resource "google_dataproc_job" "pig" {
  region       = google_dataproc_cluster.mycluster.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
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
  region       = google_dataproc_cluster.mycluster.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }
  sparksql_config {
    query_list = [
      "DROP TABLE IF EXISTS dprocjob_test",
      "CREATE TABLE dprocjob_test(bar int)",
      "SELECT * FROM dprocjob_test WHERE bar > 2",
    ]
  }
}

# Check out current state of the jobs
output "spark_status" {
  value = google_dataproc_job.spark.status[0].state
}
output "pyspark_status" {
  value = google_dataproc_job.pyspark.status[0].state
}
output "pig_status" {
  value = google_dataproc_job.pig.status[0].state
}
output "sparksql_status" {
  value = google_dataproc_job.sparksql.status[0].state
}
