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

output "gateway_cidr" {
  value = var.gateway_cidr
}

output "incus_network" {
  value = incus_network.this.name
}

output "incus_project" {
  value = incus_project.this.name
}