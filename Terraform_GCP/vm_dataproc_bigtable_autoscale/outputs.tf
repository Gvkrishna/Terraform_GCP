####################################################################################
# Output variables
####################################################################################
output "dataproc-cluster-zone" {
 value = "${var.zone}"
}

output "dataproc-gcp-project-id" {
 value = "${var.project}"
}

output "compute-vm-instance" {
 value = "${google_compute_instance.vm.name}"
}

output "google_dataproc_cluster_name" {
 value = "${google_dataproc_cluster.mydataproc.name}"
}

output "google_bigtable_instance_name"{
  value = "${google_bigtable_instance.development-instance.name}"
}

output "google_dataproc_cluster_autoscale_policy"{
  value = "${google_dataproc_autoscaling_policy.asp.id}"
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