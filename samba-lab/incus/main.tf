module "incus-project" {
  source = "./incus-project"
  project_name    = "samba-lab"
  network_name    = "samba-lab-net"
  gateway_cidr    = "172.31.254.1/24"
}

module "linux-servers" {
  source = "./linux-servers"

  instance_names  = ["samba-dc", "samba-fs"]
  image           = "images:debian/12/cloud" # cloud images have python3 preinstalled
  memory          = "1GiB"
  storage_pool    = "nvme"
  project_name    = module.incus-project.incus_project
  network_name    = module.incus-project.incus_network
  gateway_cidr    = module.incus-project.gateway_cidr
}

module "windows-clients" {
  source = "./windows-clients"

  instance_names  = ["w11pro-1"]
  image           = "w11pro" # have to build myself
  memory          = "4GiB"
  storage_pool    = "nvme"
  project_name    = module.incus-project.incus_project
  network_name    = module.incus-project.incus_network
}
