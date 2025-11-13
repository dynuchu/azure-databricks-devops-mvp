# Azure Databricks + Data Factory + Cognitive Services Integration

## Overview

This repository demonstrates a minimal **Azure-native integration** for securely calling Azure Cognitive Services from both **Azure Databricks** (via a notebook) and **Azure Data Factory** (via pipeline Web Activity).  
**All resources are provisioned via Terraform** for reproducibility and easy teardown.

The solution showcases:
- Secure management of Cognitive Services API key in **Azure Key Vault**
- Usage of **Key Vault-backed secret scope** in Databricks notebooks (no key in code)
- **Data Factory** pipeline making direct API calls with the secret (manually copied for demo)
- Modular, clear Terraform codebase for infra-as-code best practices

---

## Architecture

- **Azure Key Vault**: Stores the Cognitive Services API key (`ai-primary-key`). Populated via Terraform from the Cognitive Account.
- **Azure Cognitive Services**: Provides the API endpoint and key for language/AI analysis.
- **Azure Data Factory**:  
  - Managed Identity enabled and granted access to Key Vault.  
  - Pipeline with a **Web Activity** calling the Cognitive Services API, with the key entered manually in the header (for demo simplicity).
- **Azure Databricks Workspace**:  
  - **Cluster** for execution  
  - **Notebook** using a Key Vault-backed **Secret Scope** to securely retrieve the API key (`dbutils.secrets.get("kv", "ai-primary-key")`), and make a POST request to the Cognitive endpoint.
  - **Job** to run the notebook with parameters.
- **Azure Storage Account**: Deployed for completeness, not directly used in this demo.

---

## Solution Flow

### Databricks

1. **Notebook** retrieves the API key from Key Vault via Secret Scope:
    ```python
    ai_key = dbutils.secrets.get(scope="kv", key="ai-primary-key")
    ```
2. The notebook builds a JSON payload and makes a **POST** request to the Azure Cognitive Services endpoint.
3. **Cluster** is pre-created via Terraform, so compute is always available.

### Data Factory

1. **Web Activity** in the pipeline calls the Cognitive Services endpoint.
2. For this demo, the API key is **manually copied** from Key Vault and set in the header.
3. (No automated “Get Secret” activity implemented yet.)

---

## Folder Structure
```
terraform/
│
├── adf_wiring.tf # Data Factory pipeline, linked service, etc.
├── ai.tf # Cognitive Account, Key Vault Secret, policies
├── data.tf # Data sources
├── databricks_job.tf # Databricks cluster, notebook, job, directory
├── databricks_secret.tf # Secret scope for Key Vault in Databricks
├── locals.tf # Local variables
├── main.tf # Resource group, storage, key vault, workspace
├── outputs.tf # Outputs for URLs, IDs, etc.
├── providers.tf # Provider and backend configs
├── variables.tf # All variable declarations
├── .gitignore
└── README.md # This file
```

---

## Quickstart

### Prerequisites

- Azure subscription and permissions to create resources
- Terraform CLI (>= 1.5.0)
- Databricks and Azure CLI authenticated (`az login`)
- Python installed (if testing Databricks notebook locally)

### Deployment

1. Clone the repo and enter the `demo/terraform` directory.
2. Initialize Terraform:
    ```sh
    terraform init
    ```
3. Review/change variables in `variables.tf` as needed (location, prefix, suffix).
4. Apply the configuration:
    ```sh
    terraform apply
    ```
5. Wait for resources to be provisioned (note: Databricks cluster startup may take several minutes).

### Manual Steps

- In **Data Factory**, open the pipeline `pl-ai-web-call` and paste the **API key** from Key Vault into the Web Activity header (`Ocp-Apim-Subscription-Key`).
- In **Databricks**, the secret scope should be available as `kv` (test with `dbutils.secrets.listScopes()`).

---

## Security Notes

- **Key Vault** holds the Cognitive Services key; never store secrets in code or notebooks.
- Both ADF and Databricks use **managed identities** (no hardcoded credentials).
- The current demo pipeline in ADF does **not** fetch the secret automatically; in production, use an extra “Get Secret” activity for runtime retrieval.
- Databricks notebook uses **Key Vault-backed Secret Scope** for secure secret injection.

---

## Customization & Extensions

- Implement “Get Secret” activity in ADF for full runtime security (see comments in `adf_wiring.tf`).
- Parameterize the Cognitive Services endpoint and key location.
- Add diagnostic settings, Private Endpoints, or network restrictions as needed for production.

---

## Useful Links

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Databricks Provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
- [Key Vault-backed Secret Scopes](https://learn.microsoft.com/en-us/azure/databricks/security/secrets/secret-scopes)
- [Azure Data Factory Web Activity](https://learn.microsoft.com/en-us/azure/data-factory/control-flow-web-activity)
- [Azure Cognitive Services Docs](https://learn.microsoft.com/en-us/azure/cognitive-services/)


