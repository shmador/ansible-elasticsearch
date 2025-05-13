# ansible-elasticsearch

A combined **Terraform** and **Ansible** solution to provision and configure an Elasticsearch cluster on AWS EC2.

## Overview

This project automates the deployment of a multi-node Elasticsearch cluster on Amazon AWS. The Terraform scripts launch EC2 instances, set up networking (VPC, security group rules for Elasticsearch), and generate an SSH key pair. The custom Ansible role (`elasticsearch/`) then installs and configures Elasticsearch on those instances, forming a cluster. This separation of concerns—Terraform for infrastructure and Ansible for software configuration—makes the setup reproducible and easy to maintain.

## Main Features

- **Custom Ansible Role:** A dedicated role in `elasticsearch/` installs and configures Elasticsearch on each node. It handles package installation, service setup, and cluster configuration automatically.  
- **OS Support:** Works on both Debian-family (e.g. Ubuntu) and RedHat-family (e.g. CentOS/RHEL) Linux distributions. The role detects the OS and uses the appropriate package manager (APT or YUM) and service commands.  
- **Version Selection:** You can specify the Elasticsearch version via Ansible variables (e.g. `es_version` in `defaults/main.yml`), allowing deployment of any supported 6.x or 7.x release.  
- **Optional Security:** Enables optional X-Pack security features through variables. For example, setting a flag can turn on TLS and authentication on the Elasticsearch cluster.  
- **Terraform Provisioning:** The Terraform configuration (`main.tf`) creates AWS resources: it launches EC2 instances (one per cluster node by default), creates a security group (opening ports 9200 for HTTP and 9300 for transport), and generates an SSH key pair. The private key is saved locally for Ansible to use, and the public key is registered with AWS.  
- **Terraform & Ansible Integration:** After provisioning, Terraform outputs are used to generate an Ansible inventory (`inventory/hosts.ini`) listing the new EC2 instances. The included `ansible.cfg` is pre-configured to use this inventory and the generated SSH key. Ansible then targets these hosts to apply the Elasticsearch role.  
- **Automation Script:** A `run.sh` Bash script ties everything together for CI-like automation. Executing `run.sh` will automatically run Terraform and then the Ansible playbook in sequence, enabling one-command deployment of the full cluster.

## Requirements

- **AWS Account:** You must have an AWS account with permissions to create EC2 instances, security groups, and key pairs.  
- **Terraform (v0.12+):** Terraform must be installed and in your `PATH`. This project’s configuration is written for Terraform 0.12 or later.  
- **Ansible (v2.9+):** Ansible must be installed (version 2.9 or later recommended) to run the playbooks and roles.  
- **AWS Credentials:** Configure your AWS credentials so that Terraform can authenticate (e.g. by exporting `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, or by configuring the AWS CLI).  
- **SSH Key:** The Terraform provisioning will generate an SSH key pair automatically. The private key is stored in the project directory (as specified in `ansible.cfg`), and Ansible is configured to use this key to SSH into the EC2 instances.

## Setup and Usage

### 1. Terraform Provisioning

1. **Initialize Terraform:** In the project root (where `main.tf` resides), run:
   ```bash
   terraform init
   ```
2. **Apply Terraform:** Create the AWS resources:
   ```bash
   terraform apply
   ```
   Confirm when prompted (or add `-auto-approve` to skip prompts). Terraform will then launch the EC2 instances, create the security group, and generate an SSH key pair.
3. **SSH Key Output:** After apply, Terraform saves the private SSH key (e.g. `ansible-elasticsearch.pem`) in the project directory. The `ansible.cfg` file is pre-configured to use this key for SSH connections. 

### 2. Running the Ansible Playbook

After Terraform finishes, configure the software stack with Ansible:

1. **Check Inventory:** Terraform populates `inventory/hosts.ini` with the new instance IPs under a group (e.g. `[elasticsearch_nodes]`). This inventory file and SSH key are already referenced by `ansible.cfg`.
2. **Run Ansible:** Execute the main playbook to install Elasticsearch on all nodes:
   ```bash
   ansible-playbook -i inventory/hosts.ini main.yml
   ```
   Ansible will SSH into each EC2 instance, install the specified version of Elasticsearch, configure the cluster, and start the service.

### 3. Full Automation (`run.sh`)

For convenience, the `run.sh` script automates both Terraform and Ansible steps:

```bash
chmod +x run.sh
./run.sh
```

This script will (in order) initialize and apply the Terraform configuration, then run the Ansible playbook using the generated inventory and key. It’s ideal for CI/CD pipelines or demo setups, allowing a complete deployment with a single command.

---

You will no have a running Elasticsearch cluster on AWS. You can connect to any node (its public DNS/IP) on port 9200 to interact with the cluster’s REST API. Adjust any cluster-specific settings (such as index or security configurations) via Ansible variables or additional playbooks as needed.
