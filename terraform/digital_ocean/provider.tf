terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.42.0"
    }
  }
}

variable "do_api_token" {
    type = string
}

provider "digitalocean" {
    token = var.do_api_token
}
