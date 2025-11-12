# Azure Databricks DevOps MVP

Minimal reproducible demo showing:
- Terraform-based Azure infrastructure (RG, KV, Storage, Databricks WS)
- Databricks notebook + job deployment
- (Optional) Azure Data Factory and AI Services integration
- Ready for extension to CI/CD (Azure DevOps / GitHub Actions)

🛠️ Built by **Agnes Bosskay** | Cloud & DevOps Engineer  
LinkedIn: [linkedin.com/in/agnesbosskay](https://linkedin.com/in/agnesbosskay)

## 🔷 Architecture Overview

```mermaid
flowchart LR
  subgraph TF["Terraform apply"]
    TF-->RG
  end

  subgraph RG["Resource Group"]
    KV["Azure Key Vault\n(ai-primary-key)"]
    AI["Azure Cognitive Services\n(CognitiveAccount)"]
    ADF["Azure Data Factory\n(Managed Identity)"]
    DBW["Azure Databricks Workspace"]
    STG["Storage Account (demo)"]
  end

  subgraph DBW2["Databricks Workspace"]
    CL["Cluster (demo-cluster)"]
    NB["Notebook: /Workspace/Shared/demo/hello"]
    JOB["Databricks Job"]
    SCOPE["Secret Scope: kv\n(Key-Vault-backed)"]
  end

  RG --- DBW2
  TF --> KV
  TF --> AI
  TF --> ADF
  TF --> DBW
  TF --> STG
  TF -->|create| JOB
  TF -->|upload| NB
  TF -->|create| CL
  TF -->|create| SCOPE
  TF -->|set value| KV

  AI -->|primary_access_key| KV
  SCOPE --- KV

  JOB -->|runs on| CL
  NB -->|"dbutils.secrets.get(scope=kv, key=ai-primary-key)"| SCOPE
  NB -->|HTTP POST| AI

  ADF -->|"Get Secret (AzureKeyVault activity)"| KV
  ADF -->|"Web Activity (Header → Ocp-Apim-Subscription-Key)"| AI
