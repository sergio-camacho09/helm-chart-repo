# README: Deploy Helm Chart to GKE Using Ansible and GitHub Actions

This README provides a comprehensive explanation of the GitHub Actions workflow designed to deploy a Helm chart into a Google Kubernetes Engine (GKE) cluster using an Ansible playbook. The solution leverages a pre-existing `vars.yaml` file for dynamic variables and assumes that secrets are securely stored in the GitHub repository.

---

## Workflow Overview

The workflow, located at `.github/workflows/ansible-workflow.yaml`, performs the following tasks:

1. Checks out the repository.
2. Sets up Ansible for executing the playbook.
3. Installs Helm and Google Cloud SDK (gcloud).
4. Executes the Ansible playbook to manage Helm charts between registries.

---

## Workflow Steps in Detail

### Step 1: Checkout the Repository

The `actions/checkout` action retrieves the repository code, ensuring access to the Ansible playbook and `vars.yaml` file.

```yaml
- name: Checkout code
  uses: actions/checkout@v3
```

### Step 2: Set Up Ansible

Installs Ansible to enable the execution of the playbook.

```yaml
- name: Set up Ansible
  run: |
    sudo apt update
    sudo apt install -y ansible
    ansible --version
```

### Step 3: Install Helm and Google Cloud SDK

Installs Helm for managing Kubernetes packages and gcloud for interacting with Google Cloud resources.

```yaml
- name: Install Helm and gcloud
  run: |
    sudo snap install helm --classic
    sudo apt-get install -y apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt-get update
    sudo apt-get install -y google-cloud-sdk
    gcloud version
```

### Step 4: Execute the Ansible Playbook

Runs the Ansible playbook to synchronize Helm charts between the reference registry and the instance registry.

```yaml
- name: Execute Ansible Playbook
  run: |
    ansible-playbook -i localhost, playbook.yml
  env:
    GCP_SA_KEY_FILE: ${{ secrets.GCP_SA_KEY_FILE }}
    PROJECT_ID: ${{ secrets.PROJECT_ID }}
    REFERENCE_REGISTRY: ${{ secrets.REFERENCE_REGISTRY }}
    INSTANCE_REGISTRY: ${{ secrets.INSTANCE_REGISTRY }}
```

---

## Prerequisites

### Required Files

1. **Ansible Playbook**: The `sync_helm_charts.yaml` file contains tasks for synchronizing Helm charts between registries.
2. **`vars.yaml` File**: A file defining dynamic variables used in the playbook. Ensure it is present in the repository.

### GitHub Secrets

Add the following secrets to your repository:

- `GCP_SA_KEY_FILE`: Path to the GCP service account key file.
- `PROJECT_ID`: Google Cloud project ID.
- `REFERENCE_REGISTRY`: URL of the reference Helm registry.
- `INSTANCE_REGISTRY`: URL of the instance Helm registry.

---

This workflow and README provide a complete solution for deploying Helm charts to a GKE cluster using GitHub Actions and Ansible.