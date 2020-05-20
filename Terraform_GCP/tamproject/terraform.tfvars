
#Staging bucket, used used to stage files, such as Hadoop jars, between client machines and the cluster.
#staging_bucket = "[YOUR-BUCKET-NAME]"

# Variable values go here
#
#Enter your project ID
#project = "postgresql-276510"


#Enter your region
#region = "us-central1"
# WARNING: Since these values often contain sensitive information, don't commit
# this file to version control.


# replace with n1-standard-1 if you only want to test
#machine_types = {
#  "master" = "n1-standard-1"
#  "worker" = "n1-standard-1"
#}
#count_server = {
#  "worker" = "2"
#  "master" = "1"
#  "preemptible" = "0"
#



#cidrs = [ "10.0.0.0/16", "10.1.0.0/16" ]

# replace with a service account you want to be used in the VMs to be created
# leave in blank if you want to use a new service account
#service_account = "PROJECT_SERVICE_ACCOUNT@xxx.gserviceaccount.com"
#service_account = "postgres@postgresql-276510.iam.gserviceaccount.com"