terraform {
  required_version = ">= 1.10.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }

    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 6.0.0"
    }
  }
}

provider "openstack" {
  insecure = true
}

provider "rancher2" {
  api_url   = "https://${module.rancher_node.public_ipv4}.sslip.io"
  insecure  = true
  bootstrap = true
  timeout   = "30m"
}
