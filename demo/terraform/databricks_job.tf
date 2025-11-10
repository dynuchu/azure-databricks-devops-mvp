resource "databricks_notebook" "hello" {
  path     = "/Workspace/Shared/demo/hello"
  language = "PYTHON"
  content_base64 = base64encode(<<-PY
    # Databricks notebook source
    # COMMAND ----------
    print("Hello from Databricks job! 🚀")
    PY
  )
}

resource "databricks_job" "demo" {
  name = "${var.prefix}-hello-job"

  job_cluster {
    job_cluster_key = "jcluster"
    new_cluster {
      spark_version = "13.3.x-scala2.12"
      node_type_id  = "Standard_DS3_v2"
      num_workers   = 1
    }
  }

  task {
    task_key        = "run-notebook"
    job_cluster_key = "jcluster"
    notebook_task {
      notebook_path = databricks_notebook.hello.path
    }
  }
}