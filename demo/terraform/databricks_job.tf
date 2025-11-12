resource "databricks_directory" "demo_dir" {
  path = "/Workspace/Shared/demo"
}

resource "databricks_notebook" "hello" {
  path     = "/Workspace/Shared/demo/hello"
  language = "PYTHON"
  content_base64 = base64encode(<<-PY
    # Databricks notebook source
    # COMMAND ----------
    import requests, json

    try:
        AI_ENDPOINT = dbutils.widgets.get("AI_ENDPOINT")
    except Exception:
        AI_ENDPOINT = "${azurerm_cognitive_account.ai.endpoint}"

    ai_key = dbutils.secrets.get(scope="kv", key="ai-primary-key")
    url = f"{AI_ENDPOINT}/language/:analyze-text?api-version=2023-04-01"
    headers = {"Ocp-Apim-Subscription-Key": ai_key, "Content-Type": "application/json"}
    payload = {
    "kind": "KeyPhraseExtraction",
    "parameters": {"modelVersion": "latest"},
    "analysisInput": {
        "documents": [
        {"id":"1","language":"en","text":"Databricks with Azure AI services is a powerful combo."}
        ]
    }
    }
    resp = requests.post(url, headers=headers, data=json.dumps(payload), timeout=30)
    print("Status:", resp.status_code)
    print(resp.text)
    PY
  )
}

resource "databricks_cluster" "demo_compute" {
  cluster_name            = "demo-cluster"
  spark_version           = "13.3.x-scala2.12"
  node_type_id            = "Standard_D3_v2"
  num_workers             = 1
  autotermination_minutes = 15
}


resource "databricks_job" "demo" {
  name = "${var.prefix}-hello-job"

  task {
    task_key            = "run-notebook"
    existing_cluster_id = databricks_cluster.demo_compute.id
    notebook_task {
      notebook_path = databricks_notebook.hello.path
      base_parameters = {
        AI_ENDPOINT = azurerm_cognitive_account.ai.endpoint
      }
    }
  }
}
