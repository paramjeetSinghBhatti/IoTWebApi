terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
    features{}
}

# move our terraform state file to a blob storage
terraform{
  backend "azurerm" {
    resource_group_name = "tf_rg_storage"
    storage_account_name = "tfstorageaccountpsbhatti"
    container_name ="tfstatecontainer"
    key= "iot_terraform.tfstate"
  }
}

# Resource Group
resource "azurerm_resource_group" "IotSample" {
  name     = "iot_sample_rg"
  location = "Germany West Central"
}

variable "DB_PASSWORD" {
  description = "The database password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "DB_USER" {
  description = "The database user for the SQL Server."
  type        = string
  sensitive   = false
}

variable "DB_NAME" {
  description = "The database name for the SQL Server."
  type        = string
  sensitive   = false
}

variable "imagebuild" {
  type        = string
  description = "Latest build Image tag value."
}

# SQL Server container setup
resource "azurerm_container_group" "sql_server_container" {
  name                = "iot_sqlserver-container"
  location            = azurerm_resource_group.IotSample.location
  resource_group_name = azurerm_resource_group.IotSample.name
  os_type             = "Linux"
  ip_address_type = "Public"
  tags                = {
    environment = "production"
  }

  container {
    name   = "sqlserver"
    image  = "mcr.microsoft.com/mssql/server:2022-latest"
    cpu    = "2"
    memory = "4.0"

    environment_variables = {
      "ACCEPT_EULA"    = "Y"
      "MSSQL_SA_PASSWORD" = var.DB_PASSWORD  # Use a secure password
      "MSSQL_PID"      = "Developer"
    }

    ports {
      port     = 1433
      protocol = "TCP"
    }
  }
}

# Output the IP address of the SQL Server container
output "iot_sql_server_ip" {
  value = azurerm_container_group.sql_server_container.ip_address
}

# Web API in a Container
resource "azurerm_container_group" "iot_container_grp" {
  depends_on = [azurerm_container_group.sql_server_container]
  name                = "webapi-container"
  resource_group_name = azurerm_resource_group.IotSample.name
  location            = azurerm_resource_group.IotSample.location
  os_type             = "Linux"
  ip_address_type = "Public"
  dns_name_label = "iotsample-bhatti"

  container {
    name   = "iotwebapi"
    image  = "psbhatti/iotwebapi:${var.imagebuild}"
    cpu    = 1
    memory = 1

    environment_variables = {
      "DB_SERVER"   = azurerm_container_group.sql_server_container.ip_address
      "DB_NAME"     = var.DB_NAME
      "DB_USER"     = var.DB_USER
      "DB_PASSWORD" = var.DB_PASSWORD # Match MSSQL_SA_PASSWORD from SQL container
     }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}

# Output the container name of the iot web api
output "iot_webapi_container" {
  value = azurerm_container_group.iot_container_grp.name
}

# Output the DNS name of the Web API container
output "iot_webapi_dns_name" {
  value       = azurerm_container_group.iot_container_grp.fqdn
  description = "The DNS name of the Web API container."