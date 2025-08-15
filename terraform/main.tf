# initial setup only
data "digitalocean_ssh_key" "local" {
  name = "my_local"
}

# create on jump after setup
data "digitalocean_ssh_key" "jump" {
  name = var.jumpbox_provisioned ? "jumpbox" : data.digitalocean_ssh_key.local.name
}

resource "digitalocean_vpc" "k8s_vpc" {
  name     = "k8s-vpc"
  region   = var.region
  ip_range = "10.0.0.0/16"
}

resource "digitalocean_droplet" "jumpbox" {
  image    = "debian-12-x64"
  name     = "jumpbox"
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  vpc_uuid = digitalocean_vpc.k8s_vpc.id
  ssh_keys = [data.digitalocean_ssh_key.local.id]
}

resource "digitalocean_droplet" "server" {
  image    = "debian-12-x64"
  name     = "server"
  region   = var.region
  size     = "s-1vcpu-2gb"
  vpc_uuid = digitalocean_vpc.k8s_vpc.id
  ssh_keys = [data.digitalocean_ssh_key.jump.id]
}

resource "digitalocean_droplet" "node" {
  count    = 2
  image    = "debian-12-x64"
  name     = "node-${count.index}"
  region   = var.region
  size     = "s-1vcpu-2gb"
  vpc_uuid = digitalocean_vpc.k8s_vpc.id
  ssh_keys = [data.digitalocean_ssh_key.jump.id]
}

output "machine_ips" {
  value = {
    jumpbox = {
      public_ip  = digitalocean_droplet.jumpbox.ipv4_address
      private_ip = digitalocean_droplet.jumpbox.ipv4_address_private
    }
    server = {
      public_ip  = digitalocean_droplet.server.ipv4_address
      private_ip = digitalocean_droplet.server.ipv4_address_private
    }
    node-0 = {
      public_ip  = digitalocean_droplet.node[0].ipv4_address
      private_ip = digitalocean_droplet.node[0].ipv4_address_private
    }
    node-1 = {
      public_ip  = digitalocean_droplet.node[1].ipv4_address
      private_ip = digitalocean_droplet.node[1].ipv4_address_private
    }
  }
}
