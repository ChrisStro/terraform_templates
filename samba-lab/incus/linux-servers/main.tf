locals {
  first_usable_ip  = 11
  ip_subnet = join(".", slice(split(".", var.gateway_cidr), 0, 3))
}

resource "incus_profile" "this" {
  project     = var.project_name
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
      "network" = var.network_name
      "name"    = "eth0"
    }
  }
}

resource "incus_instance" "instances" {
  for_each = var.instance_names

  project  = var.project_name
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
      "network" = var.network_name
      "name"    = "eth0"
      "ipv4.address"  = "${local.ip_subnet}.${local.first_usable_ip + index(tolist(var.instance_names), each.value) + 1}"
    }
  }

  lifecycle {
    ignore_changes = [ running ]
  }
}