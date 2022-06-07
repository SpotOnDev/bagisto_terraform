resource "aws_cloudwatch_metric_alarm" "blue_scale_up" {
  alarm_description   = "Monitors CPU utilization for web-app ASG"
  alarm_actions       = [aws_autoscaling_policy.blue_scale_up.arn]
  alarm_name          = "blue_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "25"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blue.name
  }
}

resource "aws_cloudwatch_metric_alarm" "blue_scale_down" {
  alarm_description   = "Monitors CPU utilization for web-app ASG"
  alarm_actions       = [aws_autoscaling_policy.blue_scale_down.arn]
  alarm_name          = "blue_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blue.name
  }
}
resource "aws_cloudwatch_metric_alarm" "green_scale_up" {
  alarm_description   = "Monitors CPU utilization for web-app ASG"
  alarm_actions       = [aws_autoscaling_policy.green_scale_up.arn]
  alarm_name          = "green_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "25"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.green.name
  }
}

resource "aws_cloudwatch_metric_alarm" "green_scale_down" {
  alarm_description   = "Monitors CPU utilization for web-app ASG"
  alarm_actions       = [aws_autoscaling_policy.green_scale_down.arn]
  alarm_name          = "green_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.green.name
  }
}