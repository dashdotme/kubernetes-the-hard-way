terraform {
  required_version = "~> 1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.00"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }

  backend "azurerm" {
    resource_group_name  = "k8s-the-hard-way"
    storage_account_name = "dashdotmek8s"
    subscription_id      = "cfab30b4-6a5f-407d-9346-a633a3620ba5"
    container_name       = "tfstate"
    key                  = "k8s-the-hard-way.terraform.tfstate"
    snapshot             = true
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

provider "digitalocean" {
  token = var.do_token
}
