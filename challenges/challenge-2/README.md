# Helm Charts Migration Automation

This README provides a detailed explanation of the provided Ansible playbook, which automates the migration of Helm charts between a reference GCP Artifact Registry (`reference.gcr.io`) and an instance-specific GCP Artifact Registry (`instance.gcr.io`).

## Overview

The playbook performs the following steps:

1. **Authenticate with GCP**: Ensures the user is authenticated and the appropriate GCP project is set.
2. **Download Helm charts**: Pulls Helm charts from the reference registry.
3. **Push Helm charts to instance registry**: Packages the charts and uploads them to the instance registry.

---

## Prerequisites

Before running the playbook, ensure the following:

- **Authentication**: The user must be authenticated with GCP and have sufficient permissions to access both the reference and instance artifact registries.
- **Dependencies**:
  - Ansible installed on the control machine.
  - Helm CLI installed on the managed node.
  - GCP SDK installed on the managed node.
- **Environment Configuration**: Provide the necessary GCP credentials and project configuration.

---

## Variables

The playbook uses the following variables defined in the `variables.yml` file:

| Variable Name          | Description                                         |
| ---------------------- | --------------------------------------------------- |
| `gcp_credentials_file` | Path to the GCP service account JSON key file.      |
| `gcp_project`          | GCP project ID.                                     |
| `reference_registry`   | URL of the reference GCP Artifact Registry.         |
| `instance_registry`    | URL of the instance-specific GCP Artifact Registry. |
| `helm_charts`          | List of Helm charts to migrate.                     |

---

## Playbook Explanation

### **1. Authenticate with GCP**

This task authenticates the user with GCP and sets the appropriate project:

```yaml
- name: Authenticate with GCP
  shell: |
    gcloud auth activate-service-account --key-file="{{ gcp_credentials_file }}"
    gcloud config set project "{{ gcp_project }}"
```

- **Purpose**: Ensures the playbook has access to GCP services.
- **Key Variable**: `gcp_credentials_file` specifies the credentials file for authentication.

### **2. Pull Helm Charts from Reference Registry**

This task downloads Helm charts from the reference registry:

```yaml
- name: Pull Helm charts from reference registry
  shell: |
    helm repo add reference https://{{ reference_registry }}/helm-charts
    helm repo update
    helm pull reference/{{ item }} --untar --untardir /tmp/helm_charts/
  loop: "{{ helm_charts }}"
  register: pull_results
```

- **Purpose**: Downloads the specified charts to a temporary directory.
- **Key Features**:
  - **`loop`**: Iterates over the list of charts defined in `helm_charts`.
  - **`register`**: Captures the results of the `helm pull` command for later use.

### **3. Push Helm Charts to Instance Registry**

This task uploads the downloaded Helm charts to the instance registry:

```yaml
- name: Push Helm charts to instance registry
  shell: |
    helm package /tmp/helm_charts/{{ item }}
    helm push /tmp/helm_charts/{{ item }} https://{{ instance_registry }}/helm-charts
  loop: "{{ pull_results.results | map(attribute='item') | list }}"
```

- **Purpose**: Packages and uploads each chart to the destination registry.
- **Key Features**:
  - **Dynamic Loop**: Uses the results of the previous task (`pull_results`) to determine which charts to upload.

---

## How to Run the Playbook

1. Clone the repository containing the playbook.
2. Populate the `variables.yml` file with the required values:

```yaml
gcp_credentials_file: "/path/to/credentials.json"
gcp_project: "my-gcp-project"
reference_registry: "reference.gcr.io"
instance_registry: "instance.gcr.io"
helm_charts:
  - chart1
  - chart2
```

3. Run the playbook:

```bash
ansible-playbook -i inventory.yml playbook.yml
```

---

## Additional Notes

- Ensure that `helm` and `gcloud` are installed and properly configured on the target node.
- Verify that the user has the necessary IAM roles to interact with GCP Artifact Registry.
- If an error occurs during the Helm pull or push steps, inspect the `pull_results` variable for debugging information.

---

## Future Improvements

- **Error Handling**: Add conditional checks to handle failures during Helm pull or push operations.
- **Logging**: Enhance logging to provide better traceability for each operation.
- **Dynamic Registries**: Allow the reference and instance registries to be passed as command-line arguments.

---

This playbook ensures seamless migration of Helm charts between GCP Artifact Registries, enabling reliable and automated deployment workflows.

