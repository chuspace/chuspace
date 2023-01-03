provider "aws" {
  region = var.region
}

data "aws_acm_certificate" "chuspace" {
  domain      = "*.chuspace.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "template_file" "docker_compose" {
  template = file("${path.module}/data-scripts/docker-compose.yml")
}

data "template_file" "user_data_server" {
  template = file("${path.module}/data-scripts/user-data-server.sh.tpl")

  vars = {
    docker_compose          = data.template_file.docker_compose.rendered
    docker_access_token     = var.docker_access_token
    aws_access_key_id       = var.aws_access_key_id
    aws_secret_access_key   = var.aws_secret_access_key
    aws_region              = var.aws_region
    aws_ssm_secret_key_name = var.aws_ssm_secret_key_name
  }
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  most_recent = true
  owners      = ["099720109477"]
}

resource "aws_key_pair" "ssh" {
  key_name   = "chuspace-docker-app-ssh-key"
  public_key = file("${path.module}/data-scripts/chuspace-docker-app-ssh-key.pub")
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.server_security_group_id]
  count                  = var.server_count
  subnet_id              = var.public_subnets[0]
  key_name               = aws_key_pair.ssh.key_name

  tags = merge(
    {
      "Name" = "${var.name}-server-${count.index}"
    }
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data = data.template_file.user_data_server.rendered

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "app" {
  name                       = "${var.name}-lb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  security_groups            = [var.server_security_group_id]
  subnets                    = var.public_subnets
  enable_http2               = true
}

resource "aws_lb_listener" "app_https_listener" {
  load_balancer_arn = aws_lb.app.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.chuspace.arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.app_lb_target.arn
      }
    }
  }
}

resource "aws_lb_listener" "app_http_listener" {
  load_balancer_arn = aws_lb.app.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "app_lb_target" {
  name     = "chuspace-docker-app-target"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    enabled     = true
    cookie_name = "_chuspace_session"
    type        = "app_cookie"
  }

  health_check {
    port    = 3000
    path    = "/"
    matcher = "200,301,302"
  }
}

resource "aws_lb_target_group_attachment" "app_lb_target_attachment" {
  count            = var.server_count
  target_group_arn = aws_lb_target_group.app_lb_target.arn
  target_id        = element(split(",", join(",", aws_instance.app.*.id)), count.index)
  port             = 3000
}

