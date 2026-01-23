# Simple Azure Windows VM Deployment with Ansible

Deploy a single Windows Server 2022 Azure VM using Ansible.

## Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Setup Credentials
```bash
# Edit with your Azure Service Principal details
cp configs/credentials.yml.example configs/credentials.yml
nano configs/credentials.yml
```

**Required values:**
- `subscription_id` - Your Azure subscription ID
- `client_id` - App Registration client ID
- `client_secret` - App Registration client secret
- `tenant_id` - Azure tenant ID

### 3. Configure Windows VM Password
Edit `group_vars/azure_vms.yml` and change:
```yaml
vm_admin_password: "YourSecurePassword123!"
```

### 4. Deploy Windows VM
```bash
ansible-playbook playbook.yml
```

## File Structure
```
.
├── playbook.yml              # Main deployment playbook
├── inventory.ini             # VM inventory
├── ansible.cfg               # Ansible config
├── group_vars/all.yml        # Variables
├── configs/credentials.yml   # Credentials (not in git)
├── requirements.txt          # Python packages
└── README.md                 # This file
```

## After Deployment

Get VM public IP:
```bash
az vm show -d --resource-group rg-simple-vm --name simple-vm --query publicIps -o tsv
```

Connect via RDP:
```
Remote Desktop Host: <PUBLIC_IP>:3389
Username: azureuser
Password: (as configured in group_vars/azure_vms.yml)
```

## Cleanup

Delete all resources:
```bash
az group delete --name rg-simple-vm --yes
```
