terraform init
terraform apply -auto-approve

ansible-playbook -i inventory/aws_ec2.yml main.yml
