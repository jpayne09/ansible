FROM quay.io/ansible/creator-ee:latest

# Install Azure CLI
RUN pip install --no-cache-dir azure-cli

# Verify installations
RUN az --version && ansible --version
