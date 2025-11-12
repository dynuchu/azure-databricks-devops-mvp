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
graph LR

  %% --- Terraform -> Azure resources ---
  TF[Terraform apply] --> RG[Resource group]
  TF --> KV[Key Vault]
  TF --> AI[Cognitive Services]
  TF --> ADF[Data Factory]
  TF --> STG[Storage account]
  TF --> DBW[Databricks workspace]

  %% --- Databricks logical parts (no special chars) ---
  DBW --- CL[Cluster demo]
  DBW --- NB[Notebook hello]
  DBW --- JOB[Databricks job]
  DBW --- SCOPE[Secret scope kv]

  %% --- Secrets wiring ---
  AI --> KV
  SCOPE --- KV

  %% --- Runtime paths ---
  JOB --> CL
  NB --> SCOPE
  NB --> AI

  %% --- ADF option: KV then AI ---
  ADF --> KV
  ADF --> AI
