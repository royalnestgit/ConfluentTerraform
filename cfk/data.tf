
data "vault_generic_secret" "confluent_data" {
  path      = "secret/aks/${terraform.workspace}/confluent_data"

}

locals {
  ccloud_private_westus3 = jsondecode(data.vault_generic_secret.confluent_data.data["softech_cluster"])
    rest_endpoint     = local.ccloud_private_westus3.rest_endpoint
  bootstrap_endpoint    = local.ccloud_private_westus3.bootstrap_endpoint
  schema_registry = jsondecode(data.vault_generic_secret.confluent_data.data["schema_registry"]).rest_endpoint
}
