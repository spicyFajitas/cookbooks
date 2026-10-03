terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.103.0"
    }
  }
}

variable "do_api_token" {
    type = string
}

provider "digitalocean" {
    token = var.do_api_token
}
