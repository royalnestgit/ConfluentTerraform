variable "cluster_name"{
  type = map(string)
  default = {
    prod = "prod"
    dev = "dev_uat"
   }
   sensitive = false
}
variable "cluster_availability"{
  type = map(string)
  default = {
    prod = "MULTI_ZONE"
    dev = "SINGLE_ZONE"
   }
   sensitive = false
}

variable "cluster_cku"{
  type = map(string)
  default = {
    prod = 2
    dev = 1
   }
   sensitive = false
}

variable "ksql_cluster_csu"{
  type = map(string)
  default = {
    prod = 2
    dev = 1
   }
   sensitive = false
}



variable "env_name"{
  type = map(string)
  default = {
    prod = "prod"
    dev = "dev_uat"
   }
   sensitive = false
}

variable "schema_registry_package"{
  type = map(string)
  default = {
    prod = "ADVANCED"
    dev = "ESSENTIALS"
   }
   sensitive = false
}
