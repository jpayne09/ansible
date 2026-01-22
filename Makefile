.PHONY: help install syntax lint validate deploy-dev deploy-staging deploy-prod test clean

help:
	@echo "Ansible Azure IaaS VM Deployment Testing"
	@echo "=========================================="
	@echo ""
	@echo "Available commands:"
	@echo "  make install          - Install Ansible dependencies"
	@echo "  make syntax           - Check playbook syntax"
	@echo "  make lint             - Run ansible-lint on playbooks"
	@echo "  make validate         - Validate all playbooks"
	@echo "  make deploy-dev       - Deploy to development environment"
	@echo "  make deploy-staging   - Deploy to staging environment"
	@echo "  make deploy-prod      - Deploy to production environment"
	@echo "  make test             - Test deployed VMs"
	@echo "  make clean            - Clean temporary files"
	@echo ""

install:
	pip install -r requirements.txt
	ansible-galaxy collection install azure.azcollection

syntax:
	ansible-playbook playbooks/deploy_azure_vm.yml --syntax-check
	ansible-playbook playbooks/test_azure_vms.yml --syntax-check

lint:
	ansible-lint playbooks/
	ansible-lint roles/

validate: syntax lint

deploy-dev:
	ansible-playbook playbooks/deploy_azure_vm.yml -e "deployment_environment=dev"

deploy-staging:
	ansible-playbook playbooks/deploy_azure_vm.yml -e "deployment_environment=staging"

deploy-prod:
	@echo "WARNING: Deploying to production!"
	ansible-playbook playbooks/deploy_azure_vm.yml -e "deployment_environment=prod" --ask-vault-pass

test:
	ansible-playbook playbooks/test_azure_vms.yml -i inventory/hosts

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -name "*.pyc" -delete
	rm -rf .ansible/
	rm -f *.retry
