Prepare your VM to run Terraform (https://openmetal.io/docs/manuals/operators-manual/day-4/automation/terraform )

1. install Terraform; follow original docs:   

2. download `openstack.rc` file on to the machine

3. run `run openstack.rc`

4. git clone the repo you need from  

5. modify `variable.tf` file to your needs (ex. number of VMs, flavour, image, key-pair)

6. run `terraform init`

7. run `terraform plan`

8. run `terraform apply`