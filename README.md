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

  %% --- Terraform creates all resources ---
  TF([Terraform apply]) --> RG[Azure Resource Group]
  TF --> KV[Key Vault]
  TF --> AI[Azure AI Services (Cognitive Account)]
  TF --> ADF[Azure Data Factory (Managed Identity)]
  TF --> DBW[Azure Databricks Workspace]
  TF --> STG[Storage Account]

  %% --- Key Vault wiring ---
  AI -->|primary key stored| KV
  ADF -->|has access via MI| KV
  DBW -->|secret scope kv| KV

  %% --- Databricks logical components ---
  subgraph DWB[Databricks workspace]
    CL[Cluster demo-cluster]
    NB[Notebook hello]
    JOB[Databricks job]
  end

  %% --- Runtime flow ---
  JOB --> CL
  CL --> NB
  NB -->|read ai-primary-key| KV
  NB -->|HTTP POST| AI

  %% --- ADF data flow ---
  ADF -->|optional Get Secret| KV
  ADF -->|Web Activity call| AI
