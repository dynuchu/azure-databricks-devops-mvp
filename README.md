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

  %% ===== Subgraphs =====
  subgraph TFBOX["Terraform apply"]
    TFAPPLY((apply))
  end

  subgraph RG["Resource Group"]
    KV[Azure Key Vault<br/>(ai-primary-key)]
    AI[Azure Cognitive Services<br/>(CognitiveAccount)]
    ADF[Azure Data Factory<br/>(Managed Identity)]
    DBW[Azure Databricks Workspace (resource)]
    STG[Storage Account]
  end

  subgraph DWB["Databricks Workspace (logical)"]
    CL[Cluster: demo-cluster]
    NB[Notebook: /Workspace/Shared/demo/hello]
    JOB[Databricks Job]
    SCOPE[Secret Scope: kv<br/>(Key-Vault-backed)]
  end

  %% ===== Provisioning edges by Terraform =====
  TFAPPLY --> KV
  TFAPPLY --> AI
  TFAPPLY --> ADF
  TFAPPLY --> DBW
  TFAPPLY --> STG
  TFAPPLY --> JOB
  TFAPPLY --> NB
  TFAPPLY --> CL
  TFAPPLY --> SCOPE

  %% ===== Relation between Azure resource & Databricks logical workspace =====
  DBW --- DWB

  %% ===== Secrets wiring =====
  AI -- "primary_access_key" --> KV
  SCOPE --- KV

  %% ===== Runtime paths =====
  JOB -->|runs on| CL
  NB -->|"dbutils.secrets.get(scope=kv key=ai-primary-key)"| SCOPE
  NB -->|HTTP POST| AI

  %% ===== ADF path (demo vs. clean) =====
  ADF -->|"Get Secret (AzureKeyVault activity)"| KV
  ADF -->|"Web Activity (header → Ocp-Apim-Subscription-Key)"| AI
