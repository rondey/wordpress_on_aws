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
    address = aws_db_instance.wp_db.address
    db_username = var.db_username
    db_password = var.db_password
    db_name = var.db_name
    wp_efs_access_id = aws_efs_access_point.wp_efs_access.id
    wp_efs_id = aws_efs_file_system.wp_efs.id
    wp_version = var.wp_version
  }))
}

resource "aws_autoscaling_group" "wp_asg" {
  name                    = "wp_asg"
  vpc_zone_identifier     = [aws_subnet.wordpress_a.id, aws_subnet.wordpress_b.id, aws_subnet.wordpress_c.id]
  desired_capacity        = 1
  max_size                = 10
  min_size                = 1
  default_cooldown        = 300
  default_instance_warmup = 300

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
  lb_target_group_arn   = aws_lb_target_group.wp_target.arn
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


# #!/bin/bash
# sudo yum update -y
# sudo yum install -y amazon-efs-utils
# sudo yum install -y nfs-utils
# sudo yum install -y docker
# sudo usermod -a -G docker ec2-user
# newgrp docker
# sudo systemctl start docker.service
# sudo yum install -y mysql
# mysql -h terraform-20230305164934403700000001.cnal8zvnxair.eu-west-3.rds.amazonaws.com -u admin -pSNgBNrPvrCaGvcPB37g4 -e "create database IF NOT EXISTS wordpress"
# mkdir efs
# sudo mount -t efs -o tls,accesspoint=fsap-0f8510db4039458a9 fs-01f87253b5cf79375 efs
# sudo chmod 777 /efs
# docker run -p 80:80   --env WORDPRESS_DB_HOST=terraform-20230305164934403700000001.cnal8zvnxair.eu-west-3.rds.amazonaws.com --env WORDPRESS_DB_PASSWORD=SNgBNrPvrCaGvcPB37g4  --env WORDPRESS_DB_USER=admin   --volume /efs:/var/www/html --user 33:33   wordpress:latest