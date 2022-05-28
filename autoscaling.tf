data "aws_ami" "bagisto" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bagisto-test_*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["336066284413"]
}

resource "aws_launch_configuration" "web-app" {
  image_id      = data.aws_ami.bagisto.id
  instance_type = "t2.micro"
  #user_data       = file("user-data.sh")
  security_groups = [aws_security_group.internal_http.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web-app" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.web-app.name
  vpc_zone_identifier  = [aws_subnet.main.id, aws_subnet.secondary.id]

  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "bagisto_scale_up"
  autoscaling_group_name = aws_autoscaling_group.web-app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "bagisto_scale_down"
  autoscaling_group_name = aws_autoscaling_group.web-app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}