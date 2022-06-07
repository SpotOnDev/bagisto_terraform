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

resource "aws_launch_configuration" "blue" {
  image_id      = data.aws_ami.bagisto.id
  instance_type = "t2.micro"
  #user_data       = file("user-data.sh")
  key_name = "magento_test"
  security_groups = [aws_security_group.internal_http.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "green" {
  image_id      = data.aws_ami.bagisto.id
  instance_type = "t2.micro"
  #user_data       = file("user-data.sh")
  key_name = "magento_test"
  security_groups = [aws_security_group.internal_http.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "blue" {
  min_size             = local.traffic_dist_map[var.traffic_distribution]["blue"] > 0 ? 1 : 0
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.blue.name
  vpc_zone_identifier  = [aws_subnet.main.id, aws_subnet.secondary.id]

  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }
}

resource "aws_autoscaling_group" "green" {
  min_size             = local.traffic_dist_map[var.traffic_distribution]["green"] > 0 ? 1 : 0
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.green.name
  vpc_zone_identifier  = [aws_subnet.main.id, aws_subnet.secondary.id]

  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }
}


resource "aws_autoscaling_attachment" "blue" {
  autoscaling_group_name = aws_autoscaling_group.blue.id
  alb_target_group_arn    = aws_lb_target_group.blue.arn
}

resource "aws_autoscaling_attachment" "green" {
  autoscaling_group_name = aws_autoscaling_group.green.id
  alb_target_group_arn    = aws_lb_target_group.green.arn
}

resource "aws_autoscaling_policy" "blue_scale_up" {
  name                   = "blue_scale_up"
  autoscaling_group_name = aws_autoscaling_group.blue.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "blue_scale_down" {
  name                   = "blue_scale_down"
  autoscaling_group_name = aws_autoscaling_group.green.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "green_scale_up" {
  name                   = "green_scale_up"
  autoscaling_group_name = aws_autoscaling_group.blue.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "green_scale_down" {
  name                   = "green_scale_down"
  autoscaling_group_name = aws_autoscaling_group.green.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}