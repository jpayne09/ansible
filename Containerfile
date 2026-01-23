FROM quay.io/ansible/creator-ee:latest

# Install system dependencies
USER root
RUN dnf install -y gcc python3-devel || yum install -y gcc python3-devel || apt-get update && apt-get install -y gcc python3-dev

# Install Azure CLI
RUN pip install --no-cache-dir azure-cli

# Install Python dependencies from requirements.txt
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Install additional Azure management SDK packages
RUN pip install --no-cache-dir --ignore-installed \
    azure-mgmt-compute \
    azure-mgmt-network \
    azure-mgmt-storage \
    azure-mgmt-resource \
    azure-mgmt-keyvault \
    azure-mgmt-dns \
    azure-mgmt-authorization \
    azure-mgmt-batch \
    azure-mgmt-cdn \
    azure-mgmt-monitor \
    azure-mgmt-servicebus \
    azure-mgmt-eventhub \
    azure-mgmt-web \
    azure-mgmt-rdbms \
    azure-mgmt-sql \
    azure-mgmt-redis \
    azure-mgmt-containerinstance \
    azure-mgmt-automation \
    azure-mgmt-loganalytics \
    azure-mgmt-databox \
    azure-mgmt-datafactory \
    azure-mgmt-datashare \
    azure-mgmt-deploymentmanager \
    azure-mgmt-deviceupdate \
    azure-mgmt-edgezones \
    azure-mgmt-education \
    azure-mgmt-elastic \
    azure-mgmt-elasticsan \
    azure-mgmt-synapse \
    azure-mgmt-advisor \
    azure-mgmt-apicenter \
    azure-mgmt-apimanagement \
    azure-mgmt-applicationinsights \
    azure-mgmt-attestation \
    azure-mgmt-automanage \
    azure-mgmt-avs \
    azure-mgmt-billing \
    azure-mgmt-botservice \
    azure-mgmt-certificateregistration \
    azure-mgmt-chaos \
    azure-mgmt-cognitiveservices \
    azure-mgmt-communication \
    azure-mgmt-confluent \
    azure-mgmt-confidentialledger \
    azure-mgmt-connectedvmware \
    azure-mgmt-consumption \
    azure-mgmt-containerregistry \
    azure-mgmt-containerservice \
    azure-mgmt-cosmosdb \
    azure-mgmt-costmanagement \
    azure-mgmt-customproviders \
    azure-mgmt-datadog \
    azure-mgmt-datalake-analytics \
    azure-mgmt-datamigration \
    azure-mgmt-databasewatcher \
    azure-mgmt-databricks \
    azure-mgmt-dataprotection \
    azure-mgmt-notificationhubs \
    azure-identity \
    msrest \
    msrestazure \
    pyyaml \
    jinja2 \
    requests

# Install Ansible Azure collection
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml

# Verify installations
RUN az --version && ansible --version && ansible-galaxy collection list | grep azure
