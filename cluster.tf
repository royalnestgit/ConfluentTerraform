resource "confluent_environment" "env_resource" {
  display_name = "${lookup(var.env_name, terraform.workspace)}"
}

data "confluent_organization" "SoftechConfluent" {}
data "confluent_schema_registry_region" "schema_westus3" {
  cloud   = "AZURE"
  region  = "westus3"
  package = "${lookup(var.schema_registry_package, terraform.workspace)}"
}
data "confluent_schema_registry_region" "schema_westus2" {
  cloud   = "AZURE"
  region  = "westus2"
  package = "${lookup(var.schema_registry_package, terraform.workspace)}"
}
resource "confluent_schema_registry_cluster" "cc_schema_registry_westus3" {
  package = "${lookup(var.schema_registry_package, terraform.workspace)}"

  environment {
    id = confluent_environment.env_resource.id
  }
  region {
    # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#stream-governance-regions
    # Stream Governance and Kafka clusters can be in different regions as well as different cloud providers,
    # but you should to place both in the same cloud and region to restrict the fault isolation boundary.
   id = data.confluent_schema_registry_region.schema_westus3.id
  }
  lifecycle { prevent_destroy = true }
}
resource "confluent_network" "private_link" {
  display_name     = "Private Link Network"
  cloud            = "AZURE"
  region           = "westus3"
  connection_types = ["PRIVATELINK"]
  environment {
    id = confluent_environment.env_resource.id
  }
  dns_config {
    resolution = "PRIVATE"
  }
  lifecycle { prevent_destroy = true }
}




resource "confluent_private_link_access" "private_link_access" {
  display_name = "Azure Private Link Access"
  azure {
    subscription = "${lookup(var.link_subscription, terraform.workspace)}"
  }
  environment {
    id = confluent_environment.env_resource.id
  }
  network {
    id = confluent_network.private_link.id
  }
}
resource "confluent_kafka_cluster" "softech_private_westus3" {
  display_name = "cc_${lookup(var.cluster_name, terraform.workspace)}_private_westus3"
  availability = "${lookup(var.cluster_availability, terraform.workspace)}"
  cloud        = "AZURE"
  region       = "westus3"
  dedicated {
   cku            = lookup(var.cluster_cku, terraform.workspace)
    encryption_key = ""

  }
  environment {
    id = confluent_environment.env_resource.id
  }
    network {
    id = confluent_network.private_link.id
  }
  lifecycle { prevent_destroy = true }
}

resource "confluent_ksql_cluster" "softech_private_westus3_ksqldb" {
  display_name = "cc_${lookup(var.cluster_name, terraform.workspace)}_private_westus3_ksqldb"
  csu          = lookup(var.ksql_cluster_csu, terraform.workspace)
  kafka_cluster {
    id = confluent_kafka_cluster.softech_private_westus3.id
  }
  credential_identity {
    id = confluent_service_account.sa_ksql.id
  }
  environment {
    id = confluent_environment.env_resource.id
  }
  depends_on = [
    confluent_role_binding.sa-ksql-kafka-cluster-admin,
    confluent_role_binding.sa-ksql-schema-registry-resource-owner,
    confluent_schema_registry_cluster.cc_schema_registry_westus3
  ]

  lifecycle {
    prevent_destroy = true
  }
}


resource "vault_generic_secret" "app" {
  path = "secret/it-ea/kafka/confluent/${terraform.workspace}/confluent_data"
  #path      = "secret/${module.landing_zone_rg.project_path}/dev"
  data_json = jsonencode({ softech_private_westus3 : confluent_kafka_cluster.softech_private_westus3,
  "schema_registry" : confluent_schema_registry_cluster.cc_schema_registry_westus3 ,
  softech_private_westus3_ksqldb: confluent_ksql_cluster.softech_private_westus3_ksqldb})
}




