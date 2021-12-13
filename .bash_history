gcloud auth list
gcloud config list project
gcloud iam service-accounts create terraform
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT}   --member serviceAccount:terraform@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com   --role roles/storage.admin
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT}   --member serviceAccount:terraform@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com   --role roles/compute.admin
gcloud iam service-accounts keys create     ~/service-account.json     --iam-account terraform@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
export GOOGLE_CREDENTIALS=${HOME}/service-account.json
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
touch main.tf
cloudshell edit main.tf
terraform init
terraform plan
terraform apply
cloudshell edit main.tf
terraform init
terraform plan
terraform apply
cloudshell edit main.tf
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
touch main.tf
cloudshell edit main.tf
$ terraform init
cloudshell edit main.tf
terraform init
terraform plan
terraform apply
gcloud compute instances list
cloudshell edit main.tf
terraform apply
terraform init
terraform plan
terraform apply
gcloud compute instances list
touch data.sh
cloudshell edit data.sh
terraform apply
cloudshell edit main.tf
terraform apply
cloudshell edit main.tf
terraform apply
cloudshell edit main.tf
terraform apply
terraform init
terraform plan
terraform apply
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform apply
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform apply
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform apply
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
cloudshell edit main.tf
terraform apply
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
cloudshell edit main.tf
terraform apply
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform init
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform init
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
terraform init
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
gcloud compute instances list
terraform apply
gcloud compute instances list
terraform apply
gcloud config set project VALUE
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
curl http://<10.132.0.3>:80
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform validate
gcloud compute instances list
terraform apply
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
terraform init
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform show
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform apply
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
gcloud compute instances list
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform plan
mkdir -p ~/terraform-demo/basic
cd ~/terraform-demo/basic
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
terraform apply
data.google_compute_network.name
terraform apply
curl http://<GCE_INSTANCE_PUBLIC_IP>:80
touch variables.tf
cloudshell edit variables.tf
touch outputs.tf
cloudshell edit outputs.tf
terraform apply
terraform output public_ip
terraform apply
mkdir -p ~/terraform-demo/backend
cd ~/terraform-demo/backend
touch main.tf
cloudshell edit main.tf
terraform init
terraform apply
cd ~/terraform-demo/basic
cloudshell edit main.tf
terraform init
gsutil ls -l gs://ita-terraform-state-12227/prod/state
terraform apply
cd ~/terraform-demo/basic
terraform apply
