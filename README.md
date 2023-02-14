# Kubernetes deployment with RKE

### Add your ssh keys to a new machine

```shell
chmod 0600 .ssh/id_rsa
chmod 0600 .ssh/id_rsa.pub
```


### Git clone the repo 

```shell
git clone git@github.com:stfc/terraform-openstack.git
```

### Install RKE

Find the latest release and copy the link to the binary from here https://github.com/rancher/rke/releases

```shell
wget [BINARY_LINK]
chmod +x rke_linux-amd64
mv rke_linux-amd64 /usr/local/bin/rke # or any other $PATH) 
rke --version # Check that RKE is working
```

### Set up Access to the STFC cloud
 
Copy your `PROJECT.rc` file onto the VM, then run `source [PROJECT.rc]` and enter your fedID password.


### Install conda 

Conda is needed for managing the k8s repo or install python-kubernetes, ansible, and all of the kubernetes management software (kubernetes-client, kuberentes-server, etc) into your system/distro.

```shell
wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh
bash Anaconda3-2022.10-Linux-x86_64.sh # need to answer yes
source anaconda3/bin/activate
conda init
```

May need to close the ssh session and log in again


### Conda env setup

To create a conda environment that can sustain development of this repository you can run the following command, whilst in the repository:

```shell
cd k8s/
conda env create -f k8s-conda-env.yml
conda activate k8s
helm plugin install https://github.com/databus23/helm-diff  # recommended helm plugin
```


### Cloud setup and RKE deployment in terraform:

- Go to `terraform/variables.tf` file, modify variables to your liking i.e. image, flavours, number of VMs, your fedID.
- Within `terraform/main.tf` file, you may need to set your  SSH Key name ONLY IF you don't have your ssh-keys in the cloud already.


### You are ready to run Terraform!

```shell
terraform init
terraform apply
``` 
Last command struggles with creating all the openstack VMs, this happens when doing it manually and is not related to terraform, it is due to cloud instability.


### Setup an ssh-agent for connecting to the cluster with RKE. (This may not be needed)

```shell
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa 
```

### Use terraform to output the ansible inventory into your ansible directory

```shell
terraform output -raw ansible_inventory > ../ansible/inventory.ini
```


### Use terraform to set up nodes for RKE deployment (It is recommended to run these repeatedly until they execute with no errors): 

```shell
cd ../ansible/playbooks; ansible-playbook setup-nodes.yml; cd ../terraform
```

### To acess your cluster with kubectl you will need to get rke2.yaml from controlplane.Export KUBECONFIG as an environment variable so that ansible can pick it up.

```shell
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
kubectl --kubeconfig rke2.yaml get pods --all-namespaces
```


### Run the playbook for deploying K8s tools such as Traefik, Cilium, Longhorn, Prometheus, Promtail etc.

```shell
cd ../ansible; ansible-playbook deploy-k8s-services.yml; cd ../terraform
```

--------------------------------------------------

## Things to run every time you re-open the session

```shell
source openstack.rc
conda activate k8s
export KUBECONFIG=path/to/kubeconfig
```

## To upscale an existing RKE2 cluster 

- Need to update number of workers/control nodes within `variables.tf`

- Run `terraform plan` and `terraform apply`

- Update inventory by running `terraform output -raw ansible_inventory > ../ansible/inventory.ini`

- `cd ../ansible`

- Run `ansible-playbook setup-nodes.yml -vvv` # optional -vvv flag, good for debugging

- NO NEED to rerun deploy-k8s-services.yml

- to check that new hosts/nodes are included in the cluster run `kubectl --kubeconfig rke2.yaml get pods --all-namespaces`