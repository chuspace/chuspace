provider "aws" {
  region = var.region
}

data "aws_acm_certificate" "chuspace" {
  domain      = "*.chuspace.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "template_file" "user_data_server" {
  template = file("${path.module}/data-scripts/user-data-server.sh")
}

data "aws_ami" "ubuntu" {
  filter {
    name  = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  most_recent = true
  owners      = ["099720109477"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "chuspace-app-deployer-key"
  public_key = file("${path.module}/data-scripts/chuspace-ami-key.pub")
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.server_security_group_id]
  count                  = var.server_count
  subnet_id              = var.public_subnets[0]
  key_name               = aws_key_pair.deployer.key_name

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

  user_data            = data.template_file.user_data_server.rendered
  iam_instance_profile = var.iam_instance_profile_name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  lifecycle {
    prevent_destroy = true
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

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_lb_listener" "app_https_listener" {
  load_balancer_arn = aws_lb.app.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.chuspace.arn

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
  name              = "chuspace-app-target"
  port              = 3000
  protocol          = "HTTP"
  vpc_id            = var.vpc_id
  protocol_version  = "HTTP2"

  stickiness {
    enabled     = true
    cookie_name = "_chuspace_session"
    type        = "app_cookie"
  }

  health_check {
    port      = 3000
    path      = "/"
    matcher   = "200,301,302"
  }
}

resource "aws_lb_target_group_attachment" "app_lb_target_attachment" {
  count               = var.server_count
  target_group_arn    = aws_lb_target_group.app_lb_target.arn
  target_id           = element(split(",", join(",", aws_instance.server.*.id)), count.index)
  port                = 3000
}


