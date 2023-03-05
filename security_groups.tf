resource "aws_security_group" "wp_load_balancer_sg" {
  name        = "wp_load_balancer_sg"
  description = "Security groups for load balancers"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description      = "HTTPS from public"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from public"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "wp_wordpress_sg" {
  name        = "wp_wordpress_sg"
  description = "Security groups for Wordpress instances"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description      = "HTTP from load balancers"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.wp_load_balancer_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "wp_efs_sg" {
  name        = "wp_efs_sg"
  description = "Security groups for Efs"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description      = "NFS from wp instances"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    security_groups  = [aws_security_group.wp_wordpress_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "wp_database_sg" {
  name        = "wp_database_sg"
  description = "Security groups for Database"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description      = "MySQL from wp instances"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.wp_wordpress_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}