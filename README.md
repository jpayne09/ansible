# Ansible Azure IaaS VM Deployment Testing Repository

This repository contains Ansible playbooks and roles for deploying and testing Azure Infrastructure-as-a-Service (IaaS) Virtual Machines.

## Directory Structure

```
.
├── ansible.cfg                          # Ansible configuration file
├── inventory/                           # Inventory management
│   ├── hosts                           # Inventory file with VM groups
│   ├── group_vars/                     # Group-specific variables
│   └── host_vars/                      # Host-specific variables
├── playbooks/                          # Main playbooks
│   ├── deploy_azure_vm.yml            # VM deployment playbook
│   └── test_azure_vms.yml             # VM testing and configuration
├── roles/                              # Reusable roles
│   └── azure_vm_deploy/               # Role for Azure VM deployment
│       ├── tasks/                     # Role tasks
│       ├── defaults/                  # Default variables
│       ├── vars/                      # Role-specific variables
│       └── templates/                 # Jinja2 templates
├── group_vars/                         # Global group variables
├── host_vars/                          # Global host variables
├── files/                              # Static files
├── templates/                          # Jinja2 templates
├── configs/                            # Configuration input files
│   ├── azure_credentials.yml.example  # Example credentials file
│   └── azure_subscription.txt.example # Example subscription ID file
└── README.md                           # This file
```

## Prerequisites

- Ansible 2.9+
- Azure Ansible Collections (`azure.azcollection`)
- Azure CLI or credentials configured
- SSH key pair for VM access

## Installation

### 1. Install Ansible Collections

```bash
ansible-galaxy collection install azure.azcollection
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
```

### 2. Configure Azure Credentials

Copy the example configuration files and update with your Azure details:

```bash
cp configs/azure_credentials.yml.example configs/azure_credentials.yml
cp configs/azure_subscription.txt.example configs/azure_subscription.txt
```

Edit the files with your actual Azure credentials:
- `configs/azure_credentials.yml` - Azure Service Principal or user credentials
- `configs/azure_subscription.txt` - Your Azure subscription ID

### 3. Configure SSH Keys

Ensure you have SSH keys set up:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

## Usage

### Deploy Azure VMs

Deploy VMs to the development environment:

```bash
ansible-playbook playbooks/deploy_azure_vm.yml -e "deployment_environment=dev"
```

Deploy to staging or production:

```bash
ansible-playbook playbooks/deploy_azure_vm.yml -e "deployment_environment=staging"
ansible-playbook playbooks/deploy_azure_vm.yml -e "deployment_environment=prod"
```

### Test Azure VMs

Configure and test deployed VMs:

```bash
ansible-playbook playbooks/test_azure_vms.yml -i inventory/hosts
```

### Run with Verbosity

For troubleshooting, add verbosity flags:

```bash
ansible-playbook playbooks/deploy_azure_vm.yml -vvv
```

## Configuration

### Inventory Management

Edit `inventory/hosts` to add your Azure VMs:

```ini
[azure_dev]
dev_vm ansible_host=10.0.1.100 ansible_port=22

[azure_staging]
staging_vm ansible_host=10.0.2.100 ansible_port=22

[azure_prod]
prod_vm ansible_host=10.0.3.100 ansible_port=22
```

### Group Variables

Modify `group_vars/azure_vms.yml` to change default settings:

- Azure subscription and resource group
- VM sizing and OS configuration
- Network and monitoring settings

### Role Variables

Edit `roles/azure_vm_deploy/defaults/main.yml`:

- Azure region and resource naming
- VM size and image specifications
- Network and storage configuration

## Key Features

✅ **Infrastructure as Code**: Define your Azure infrastructure using Ansible  
✅ **Role-Based Deployment**: Reusable roles for consistent deployments  
✅ **Multi-Environment Support**: dev, staging, and production configurations  
✅ **Automated Testing**: Built-in VM testing and validation playbooks  
✅ **Secure Credential Management**: Separate configs for sensitive data  
✅ **Scalable**: Deploy single or multiple VMs  

## Security Best Practices

1. **Never commit credentials**: Keep `azure_credentials.yml` in `.gitignore`
2. **Use Service Principals**: Prefer Azure Service Principal authentication
3. **Manage SSH Keys**: Store private keys securely outside the repo
4. **Encrypt Sensitive Data**: Use Ansible Vault for sensitive variables
5. **Network Security**: Use NSGs to restrict access to VMs

## Ansible Vault Usage

Encrypt sensitive variables:

```bash
ansible-vault create configs/azure_credentials.yml
ansible-playbook playbooks/deploy_azure_vm.yml --ask-vault-pass
```

## Troubleshooting

### Connection Issues

- Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Check security group rules allow SSH (port 22)
- Confirm public IP is assigned

### Azure Collection Not Found

```bash
ansible-galaxy collection list | grep azure
pip install azure-cli
```

### Permission Denied

- Verify Service Principal has proper Azure RBAC roles
- Check subscription permissions
- Review Azure activity logs for failures

## Additional Resources

- [Ansible Azure Documentation](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/)
- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

This repository is provided as-is for testing and educational purposes.
