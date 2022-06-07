resource "aws_lb" "front_end" {
  name                       = "Frontend-LB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.public_http.id]
  subnets                    = [aws_subnet.main.id, aws_subnet.secondary.id]
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-${random_pet.app.id}-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [name]
  }
}

resource "aws_lb_target_group" "green" {
  name     = "green-tg-${random_pet.app.id}-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [name]
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.blue.arn
        weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
      }

      target_group {
        arn = aws_lb_target_group.green.arn
        weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
      }

      stickiness {
        enabled = false
        duration = 1
      }
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.0.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.32.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "Secondary"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "SSH Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_http" {
  name        = "web-traffic-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "internal_http" {
  name        = "internal-http-sg"
  description = "Internal HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from LB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_http.id]
  }
  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "Internal DB traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Internal 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}