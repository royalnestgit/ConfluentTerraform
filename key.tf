



// 'app-manager' service account is required in this configuration to create 'orders' topic and assign roles
// to 'app-producer' and 'app-consumer' service accounts.
resource "confluent_service_account" "sa_admin" {
  display_name = "sa_${terraform.workspace}_admin"
  description  = "Service account to manage 'inventory' Kafka cluster"
  
  lifecycle {
    prevent_destroy = true
  }
}
resource "confluent_role_binding" "softech_private_westus3_admin_rb" {
  principal   = "User:${confluent_service_account.sa_admin.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.softech_private_westus3.rbac_crn
  
  lifecycle {
    prevent_destroy = true
  }
}
resource "confluent_role_binding" "all_subjects_essentials_rb" {
  principal   = "User:${confluent_service_account.sa_admin.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${confluent_schema_registry_cluster.ccloud_schema_registry_westus3.resource_name}/subject=*"
  
  lifecycle {
    prevent_destroy = true
  }
}


resource "confluent_api_key" "sa_admin_kafka_api_key" {
  display_name = "sa_${terraform.workspace}_admin_kafka_api_key"
  description  = "Kafka API Key that is owned by 'Softech-app-manager' service account"
  owner {
    id          = confluent_service_account.sa_admin.id
    api_version = confluent_service_account.sa_admin.api_version
    kind        = confluent_service_account.sa_admin.kind
  }
  disable_wait_for_ready = true
  managed_resource {
    id          = confluent_kafka_cluster.softech_private_westus3.id
    api_version = confluent_kafka_cluster.softech_private_westus3.api_version
    kind        = confluent_kafka_cluster.softech_private_westus3.kind

    environment {
      id = confluent_environment.env_resource.id
    }
  }
  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.softech_private_westus3_admin_rb
  ]
}
resource "confluent_api_key" "sa_admin_kafka_sr_api_key" {
  display_name = "sa_${terraform.workspace}_admin_kafka_sr_api_key"
  description  = "Schema Registry API Key that is owned by 'Softech-app-manager' service account"
  owner {
    id          = confluent_service_account.sa_admin.id
    api_version = confluent_service_account.sa_admin.api_version
    kind        = confluent_service_account.sa_admin.kind
  }
  disable_wait_for_ready = true
  managed_resource {

    id          = confluent_schema_registry_cluster.ccloud_schema_registry_westus3.id
    api_version = confluent_schema_registry_cluster.ccloud_schema_registry_westus3.api_version
    kind        = confluent_schema_registry_cluster.ccloud_schema_registry_westus3.kind

    environment {
      id = confluent_environment.env_resource.id
    }
  }
  depends_on = [
    confluent_role_binding.all_subjects_essentials_rb
  ]
}

resource "confluent_service_account" "sa_metrics" {
  display_name = "sa_${terraform.workspace}_metrics"
  description  = "Service account to manage 'inventory' Kafka cluster"
  
  lifecycle {
    prevent_destroy = true
  }
}
resource "confluent_role_binding" "sa_metrics_rb" {
  principal   = "User:${confluent_service_account.sa_metrics.id}"
  role_name   = "MetricsViewer"
  crn_pattern = data.confluent_organization.SoftechConfluent.resource_name
}



resource "confluent_api_key" "sa_metrics_api_key" {
  display_name = "sa_${terraform.workspace}_metrics_kafka_api_key"
  description  = "Kafka API Key that is owned by 'Softech-app-manager' service account"
  owner {
    id          = confluent_service_account.sa_metrics.id
    api_version = confluent_service_account.sa_metrics.api_version
    kind        = confluent_service_account.sa_metrics.kind
  }
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    confluent_role_binding.sa_metrics_rb
  ]

}





