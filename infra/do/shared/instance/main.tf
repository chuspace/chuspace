terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.20.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "chuspace_app" {
  name = "chuspace_docker_app_ssh_key"
}

data "digitalocean_certificate" "chuspace_app" {
  name = "chuspace.com"
}

data "template_file" "docker_compose" {
  template = file("${path.module}/data-scripts/docker-compose.yml")
}

data "template_file" "app_env" {
  template = file("${path.module}/data-scripts/.env")
}

data "template_file" "user_data_server" {
  template = file("${path.module}/data-scripts/user-data-server.sh.tpl")

  vars = {
    docker_compose      = data.template_file.docker_compose.rendered
    app_env             = data.template_file.app_env.rendered
    docker_access_token = var.docker_access_token
  }
}

resource "digitalocean_droplet" "app" {
  count     = var.server_count
  image     = var.image
  name      = "${var.name}-${var.region}-${count.index}"
  region    = var.region
  size      = var.instance_type
  user_data = data.template_file.user_data_server.rendered

  ssh_keys = [
    data.digitalocean_ssh_key.chuspace_app.id
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "app" {
  name                     = "${var.name}-${var.region}-loadbalancer"
  region                   = var.region
  redirect_http_to_https   = true
  enable_backend_keepalive = true

  sticky_sessions {
    type               = "cookies"
    cookie_name        = "_chuspace_session"
    cookie_ttl_seconds = "34650"
  }

  forwarding_rule {
    entry_port       = 443
    entry_protocol   = "https"
    target_port      = 3000
    target_protocol  = "http"
    certificate_name = data.digitalocean_certificate.chuspace_app.name
  }

  healthcheck {
    port                   = 3000
    protocol               = "http"
    path                   = "/heartbeat"
    check_interval_seconds = 10
  }

  droplet_ids = digitalocean_droplet.app.*.id
}

resource "digitalocean_firewall" "web" {
  name = "${var.name}-${var.region}-firewall"

  droplet_ids = digitalocean_droplet.app.*.id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "3000"
    source_load_balancer_uids = [digitalocean_loadbalancer.app.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
