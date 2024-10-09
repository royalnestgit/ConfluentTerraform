terraform {
  required_version = ">=1.3"
  backend "remote" {
    organization = "softech"
    workspaces {
      # note the trailing hyphen here...
      prefix = "Kafka-confluent-"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
# Configure the Confluent Provider

    confluent = {
      source  = "confluentinc/confluent"
      version = "1.81.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111.0"
    }
  }
}


provider "confluent" {

  cloud_api_key    = local.confluent_cloud_api_key
  cloud_api_secret = local.confluent_cloud_api_secret
}


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    api_management {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = true
    }
    #app_configuration {
    #  purge_soft_delete_on_destroy = true
    #  recover_soft_deleted         = true
    #}
    application_insights {
      disable_generated_rule = false
    }
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    template_deployment {
      delete_nested_items_during_deletion = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
    virtual_machine_scale_set {
      force_delete                  = false
      roll_instances_when_required  = true
      scale_to_zero_before_deletion = true
    }
  }
  skip_provider_registration = true
}


provider "vault" {
  add_address_to_env = true
  skip_child_token   = true
  address = "https://vault.softech.com/"
}


