# Ansible AWX Lab — AWS & Azure VM Deployment

Ansible playbooks for deploying Windows/Linux VMs on AWS EC2 and Azure, with simulated Active Directory domain join and post-deploy configuration. Designed to run from AWX/AAP.

## Repository Structure

```
├── playbooks/
│   ├── aws_deploy_ec2.yml        # Provision AWS EC2 (VPC, SG, instance)
│   ├── azure_deploy_vm.yml       # Provision Azure VM (RG, VNet, NSG, VM)
│   ├── azure_domain_join.yml     # Post-deploy: domain join Azure VM via WinRM
│   ├── aws_post_deploy.yml       # Post-deploy: configure EC2 (Windows + Linux)
│   └── teardown_all.yml          # Destroy all lab resources
├── roles/
│   ├── win_domain_join/          # Windows domain join + software install
│   └── linux_post_deploy/        # Linux hardening + realm join
├── inventory/
│   ├── aws_ec2.yml               # AWS EC2 dynamic inventory plugin
│   └── azure_rm.yml              # Azure RM dynamic inventory plugin
├── group_vars/
│   ├── aws_ec2.yml               # AWS variables (region, AMI, instance type)
│   └── azure_vms.yml             # Azure variables (RG, VM size, image)
├── configs/
│   ├── credentials.yml.example   # Credential template
│   └── credentials.yml           # Your credentials (gitignored)
├── playbook.yml                  # Original Azure-only playbook (kept for compat)
├── requirements.yml              # Ansible Galaxy collections
├── requirements.txt              # Python dependencies
├── Containerfile                 # Custom Execution Environment
└── ansible.cfg
```

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure Credentials

**For AWX:** Add credentials directly in the AWX UI (Settings → Credentials):
- **AWS**: Access Key + Secret Key
- **Azure**: Subscription ID, Client ID, Client Secret, Tenant ID

**For CLI:**
```bash
# AWS
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# Azure
export AZURE_SUBSCRIPTION_ID="your-sub-id"
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-secret"
export AZURE_TENANT_ID="your-tenant-id"
```

### 3. Deploy

```bash
# Deploy AWS EC2 Windows Server
ansible-playbook playbooks/aws_deploy_ec2.yml

# Deploy Azure Windows VM
ansible-playbook playbooks/azure_deploy_vm.yml

# Post-deploy: domain join + configure Azure VM
ansible-playbook playbooks/azure_domain_join.yml -e "target_host=<VM_IP>"

# Post-deploy: configure AWS EC2 instances
ansible-playbook playbooks/aws_post_deploy.yml -e "target_host=<VM_IP>"

# Teardown everything
ansible-playbook playbooks/teardown_all.yml -e "confirm_destroy=yes"
```

## AWX Setup

### 1. Create Project
- **Source Control Type**: Git
- **URL**: `https://github.com/jpayne09/ansible`
- **Branch**: `main`

### 2. Create Credentials
| Type | Name | Fields |
|------|------|--------|
| Amazon Web Services | `aws-lab` | Access Key, Secret Key |
| Microsoft Azure RM | `azure-lab` | Subscription ID, Client ID, Secret, Tenant |
| Machine | `winrm-admin` | Username: `Administrator`, Password: (your password) |

### 3. Create Inventory
- **Name**: `Lab Inventory`
- **Add Source**: "Sourced from a Project" → select `inventory/aws_ec2.yml` or `inventory/azure_rm.yml`
- **Or**: Use localhost for provisioning playbooks (they run locally)

### 4. Create Job Templates
| Template | Playbook | Credentials |
|----------|----------|-------------|
| AWS - Deploy EC2 | `playbooks/aws_deploy_ec2.yml` | `aws-lab` |
| Azure - Deploy VM | `playbooks/azure_deploy_vm.yml` | `azure-lab` |
| Azure - Domain Join | `playbooks/azure_domain_join.yml` | `azure-lab`, `winrm-admin` |
| AWS - Post Deploy | `playbooks/aws_post_deploy.yml` | `aws-lab`, `winrm-admin` |
| Teardown All | `playbooks/teardown_all.yml` | `aws-lab`, `azure-lab` |

### 5. Create Workflow Template
Chain the templates: **Deploy** → **Domain Join** → **Post-Deploy**

## Playbook Details

### AWS EC2 Deploy (`aws_deploy_ec2.yml`)
Creates a full VPC stack (VPC, subnet, IGW, route table, security group) and launches a Windows Server 2022 EC2 instance with WinRM enabled via UserData.

### Azure VM Deploy (`azure_deploy_vm.yml`)
Creates a resource group, VNet, subnet, NSG, public IP, NIC, and Windows Server 2022 VM. Enables WinRM via CustomScriptExtension.

### Domain Join (`azure_domain_join.yml` / `aws_post_deploy.yml`)
Connects to deployed VMs via WinRM and:
1. Sets DNS to domain controller
2. Renames computer
3. Attempts real AD domain join (`microsoft.ad.membership`)
4. Falls back to simulated join (registry + logging) if no DC available
5. Installs software via Chocolatey (Chrome, 7-Zip, Git, VSCode)
6. Applies security baseline (firewall, disable SMBv1)

### Linux Post-Deploy (role)
For Linux EC2 instances:
1. System update + essential packages
2. Service account creation
3. SSH hardening
4. Simulated realm join (sssd config)
5. UFW firewall configuration

### Teardown (`teardown_all.yml`)
Requires `-e "confirm_destroy=yes"`. Supports targeting: `all`, `aws`, or `azure`.

## Custom Execution Environment

Build the custom EE with AWS + Azure support:

```bash
podman build -t awx-azure-aws-ee:latest -f Containerfile .
```

## Customization

Edit `group_vars/aws_ec2.yml` and `group_vars/azure_vms.yml` to change:
- VM sizes, AMI IDs, regions
- Admin credentials
- Domain join parameters
- Network CIDR ranges
- Resource naming
