resource "incus_profile" "this" {
  project     = var.project_name
  name        = "windows"
  description = "Profile to be used by the Windows VMs"

  config = {
    "limits.cpu"    = "4"
    "limits.memory" = var.memory
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      "pool"    = var.storage_pool
      "path"    = "/"
      "io.bus"  = "nvme"
      "size"    = "80GiB"
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
  type     = "virtual-machine"
  image    = var.image
  profiles = ["default", incus_profile.this.name]

  lifecycle {
    ignore_changes = [ running ]
  }
}