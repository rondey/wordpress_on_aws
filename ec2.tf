resource "aws_lb_target_group" "wp_target" {
  name     = "wp-target"
  port     = 80
  protocol = "HTTP"
  stickiness {
    type = "lb_cookie"
  }
  vpc_id = aws_vpc.wp_vpc.id
}

resource "aws_lb" "wp_lb" {
  name               = "wp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wp_load_balancer_sg.id]
  subnets            = [aws_subnet.load_balancer_a.id, aws_subnet.load_balancer_b.id, aws_subnet.load_balancer_c.id]
}

resource "aws_lb_listener" "wp_lb_http" {
  load_balancer_arn = aws_lb.wp_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_target.arn
  }
}

#resource "aws_lb_listener" "wp_lb_https" {
#  load_balancer_arn = aws_lb.wp_lb.arn
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = var.arn_acm_certificate
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.wp_target.arn
#  }
#}

resource "aws_launch_template" "wp_launch" {
  name = "wp_launch"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  image_id = data.aws_ami.server_ami.id

  instance_type = var.wp_cpu_type

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.wp_wordpress_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "wp_launch"
    }
  }

  user_data = base64encode(templatefile("ec2.tpl", {
    address          = aws_db_instance.wp_db.address
    db_username      = var.db_username
    db_password      = var.db_password
    db_name          = var.db_name
    wp_efs_access_id = aws_efs_access_point.wp_efs_access.id
    wp_efs_id        = aws_efs_file_system.wp_efs.id
    wp_version       = var.wp_version
    wp_site_user     = var.site_user
    wp_site_password = var.site_password
    wp_site_email    = var.site_email
    wp_site_name     = var.site_name
    wp_site_surname  = var.site_surname
    wp_site_blog     = var.site_blog
  }))
}

resource "aws_autoscaling_group" "wp_asg" {
  name                      = "wp_asg"
  vpc_zone_identifier       = [aws_subnet.wordpress_a.id, aws_subnet.wordpress_b.id, aws_subnet.wordpress_c.id]
  desired_capacity          = 1
  min_size                  = var.min_instances_size
  max_size                  = var.max_instances_size
  default_cooldown          = 300
  default_instance_warmup   = 300
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wp_launch.id
    version = "$Latest"
  }

  # Prevents Terraform from scaling instances when it changes other aspects of the configuration
  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }

}

resource "aws_autoscaling_attachment" "wp_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.wp_asg.id
  lb_target_group_arn    = aws_lb_target_group.wp_target.arn
}

resource "aws_autoscaling_policy" "wp_asg_policy" {
  name                   = "wp-asg-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.wp_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}