# Kubernetes deployment with RKE

### Acknowledgements
This work is based on work developed by the ISIS Auto Reduction Team, whose work can be found here https://github.com/interactivereduction/k8s 

### Prerequisites 
- Ensure you can connect into an existing machine following this documentation: https://stfc-cloud-docs.readthedocs.io/en/latest/faqs.htm#how-do-i-connect-to-my-vm-using-ssh
- Install `ansible` through your package manager 


### Git clone the repo 

```shell
git clone https://github.com/stfc/terraform-openstack.git
```

### Set up Access to the STFC cloud
 
Copy your `clouds.yaml` file into the VM's `.config/openstack/`. You will need to hard-code your password under `username:`. Some additional documentation can be found here: https://stfc-cloud-docs.readthedocs.io/en/latest/Reference/PythonSDK.html#clouds-yaml 


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

Go to `terraform/variables.tf` file, modify variables to your liking i.e. image, flavours, number of VMs.

You **must** enter your fedID and keypair name to SSH into the remote machines during the Ansible step.


### You are ready to run Terraform!

```shell
cd terraform/
terraform init
terraform plan # check that settings are correct 
terraform apply # may have to run this several times
``` 
The last command may struggle creating all of the Openstack VMs, this happens when doing it manually and is not related to terraform, it is due to cloud instability.


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
conda activate k8s
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
```

## To upscale an existing RKE2 cluster 

- `cd terraform`

- Need to update number of workers/control nodes within `variables.tf`

- Run `terraform plan` and `terraform apply`

- Update inventory by running `terraform output -raw ansible_inventory > ../ansible/inventory.ini`

- `cd ../ansible`

- Run `ansible-playbook setup-nodes.yml -vvv` # optional -vvv flag, good for debugging

- There is no need to re-run `deploy-k8s-services.yml`

- To check that new hosts/nodes are included in the cluster run `kubectl --kubeconfig rke2.yaml get pods --all-namespaces`