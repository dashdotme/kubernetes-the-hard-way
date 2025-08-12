variable "subscription_id" {
  description = "Azure subscription id, for resource access."
  type = string
}

variable "do_token" {
  description = "Digitaolcean PAT, for resource access."
  type = string
  sensitive = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "syd1"
}

variable "jumpbox_provisioned" {
  type = string
  default = false
}
