module "linux-servers" {
  source = "./linux-servers"

  project_name    = "samba-lab"
  instance_names  = ["samba-dc", "samba-fs"]
  image           = "images:debian/12/cloud" # cloud images have python3 preinstalled
  memory          = "1GiB"
  network_name    = "samba-lab-net"
  storage_pool    = "nvme"
  gateway_cidr    = "172.31.254.1/24"
}

module "windows-clients" {
  source = "./windows-clients"

  project_name    = "samba-lab"
  instance_names  = ["w11pro-1"]
  image           = "w11pro" # have to build myself
  memory          = "4GiB"
  network_name    = "samba-lab-net"
  storage_pool    = "nvme"
}
