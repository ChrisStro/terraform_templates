locals {
  first_usable_ip  = 11
  ip_subnet = join(".", slice(split(".", var.gateway_cidr), 0, 3))
}

resource "incus_project" "this" {
  name        = var.project_name
  description = "Project used to test samba domains"
  config = {
    "features.images"          = false
    "features.networks"        = false
    "features.networks.zones"  = false
    "features.profiles"        = true
    "features.storage.buckets" = true
    "features.storage.volumes" = true
  }
}

resource "incus_network" "this" {
  project     = incus_project.this.name
  name        = var.network_name
  description = "Network used to test samba active directory"

  config = {
    "ipv4.address"  = var.gateway_cidr
    "ipv4.nat"      = "true"
    "ipv6.address"  = "none"
    "ipv6.nat"      = "false"
    "ipv6.dhcp"     = "false"
  }
}

resource "incus_profile" "this" {
  project     = incus_project.this.name
  name        = "samba"
  description = "Profile to be used by the cluster VMs"

  config = {
    "limits.cpu"    = "2"
    "limits.memory" = var.memory
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      "pool" = var.storage_pool
      "path" = "/"
    }
  }

  device {
    type = "nic"
    name = "eth0"

    properties = {
      "network" = incus_network.this.name
      "name"    = "eth0"
    }
  }
}

resource "incus_instance" "instances" {
  for_each = var.instance_names

  project  = incus_project.this.name
  name     = each.value
  image    = var.image
  profiles = ["default", incus_profile.this.name]

  config = {
    #"boot.autostart" = true
    "security.privileged" = true
  }

  device {
    type = "nic"
    name = "eth0"

    properties = {
      "network" = incus_network.this.name
      "name"    = "eth0"
      "ipv4.address"  = "${local.ip_subnet}.${local.first_usable_ip + index(tolist(var.instance_names), each.value) + 1}"
    }
  }

  lifecycle {
    ignore_changes = [ running ]
  }
}