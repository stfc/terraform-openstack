# Kubernetes deployment with RKE

Acknowledgements - This work is based on work developed by the ISIS Auto Reduction Team, whose work can be found here https://github.com/interactivereduction/k8s. 

### Prerequisites 
Ensure you can connect into an existing machine following this documentation: https://stfc-cloud-docs.readthedocs.io/en/latest/faqs.htm#how-do-i-connect-to-my-vm-using-ssh 


### Git clone the repo 

```shell
git clone https://github.com/stfc/terraform-openstack.git
```

### Set up Access to the STFC cloud
 
Copy your `PROJECT.rc` file onto the VM, then run `source PROJECT.rc` and enter your fedID password.


### Install conda 

Conda is needed for managing the k8s repo or install python-kubernetes, ansible, and all of the kubernetes management software (kubernetes-client, kuberentes-server, etc) into your system/distro.

```shell
wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh
bash Anaconda3-2022.10-Linux-x86_64.sh 
source anaconda3/bin/activate
conda init
```

May need to close the ssh session and log in again


### Conda env setup

To create a conda environment that can sustain development of this repository you can run the following command, whilst in the repository:

```shell
cd terraform-openstack/
conda env create -f k8s-conda-env.yml
conda activate k8s
helm plugin install https://github.com/databus23/helm-diff  # recommended helm plugin
```


### Cloud setup and RKE deployment in terraform:

- Go to `terraform/variables.tf` file, modify variables to your liking i.e. image, flavours, number of VMs, your fedID.


### You are ready to run Terraform!

```shell
cd terraform/
terraform init
terraform plan # check that settings are correct 
terraform apply # may have to run this several times
``` 
Last command struggles with creating all the openstack VMs, this happens when doing it manually and is not related to terraform, it is due to cloud instability.


### Create inventory
Use terraform to output the ansible inventory into your ansible directory

```shell
terraform output -raw ansible_inventory > ../ansible/inventory.ini
```

### Install required ansible roles and kubectl

```shell
cd ../ansible/
ansible-galaxy install -r requirements.yml
sudo snap install kubectl --classic
```

### Set up nodes

Use terraform to set up nodes for RKE deployment. You will need to run these repeatedly until they execute with no errors. 

```shell
ansible-playbook setup-nodes.yml
```

### Acess your cluster
To acess your cluster with kubectl you will need to get `rke2.yaml` from controlplane. Export KUBECONFIG as an environment variable so that ansible can pick it up.

** NB! Prior to running `kubectl`, you may need to modify the `server:` line to include one of master's IP address instead of `https://127.0.0.1:6443` **

```shell
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
kubectl get pods --all-namespaces
```


### Deploy other services
Run the playbook for deploying K8s tools such as Traefik, Cilium, Longhorn, Prometheus, Promtail etc.

```shell
ansible-playbook deploy-k8s-services.yml
```

--------------------------------------------------

## Things to run every time you re-open the session

```shell
source openstack.rc
conda activate k8s
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
```

## To upscale an existing RKE2 cluster 

- Need to update number of workers/control nodes within `variables.tf`

- Run `terraform plan` and `terraform apply`

- Update inventory by running `terraform output -raw ansible_inventory > ../ansible/inventory.ini`

- `cd ../ansible`

- Run `ansible-playbook setup-nodes.yml -vvv` # optional -vvv flag, good for debugging

- NO NEED to rerun deploy-k8s-services.yml

- to check that new hosts/nodes are included in the cluster run `kubectl --kubeconfig rke2.yaml get pods --all-namespaces`