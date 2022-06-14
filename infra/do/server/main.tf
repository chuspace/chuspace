terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.20.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "chuspace_app" {
  name = "chuspace_app"
}

data "digitalocean_certificate" "chuspace_app" {
  name = "chuspace.com"
}

resource "digitalocean_droplet" "chuspace_app" {
  count       = var.server_count
  image       = var.image
  name        = "${var.name}-${var.region}-${count.index}"
  region      = var.region
  size        = var.instance_type
  user_data   = file("${path.module}/data-scripts/user-data-server.sh")

  ssh_keys = [
    data.digitalocean_ssh_key.chuspace_app.id
  ]
}

resource "digitalocean_loadbalancer" "chuspace_app" {
  name                     = "${var.name}-${var.region}-loadbalancer"
  region                   = var.region
  redirect_http_to_https   = true
  enable_proxy_protocol    = true
  enable_backend_keepalive = true

  forwarding_rule {
    entry_port        = 443
    entry_protocol    = "https"
    target_port       = 3000
    target_protocol   = "http"
    certificate_name  = data.digitalocean_certificate.chuspace_app.name
  }

  healthcheck {
    port                   = 3000
    protocol               = "http"
    path                   = "/heartbeat"
    check_interval_seconds = 30
  }

  droplet_ids = digitalocean_droplet.chuspace_app.*.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_firewall" "web" {
  name = "${var.name}-${var.region}-firewall"

  droplet_ids = digitalocean_droplet.chuspace_app.*.id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_load_balancer_uids = [digitalocean_loadbalancer.chuspace_app.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  lifecycle {
    prevent_destroy = true
  }
}
