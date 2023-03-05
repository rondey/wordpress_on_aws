resource "aws_vpc" "wp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "wp_vpc"
  }
}

resource "aws_subnet" "load_balancer_a" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "load_balancer_a"
  }
}

resource "aws_subnet" "load_balancer_b" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3b"

  tags = {
    Name = "load_balancer_b"
  }
}

resource "aws_subnet" "load_balancer_c" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3c"

  tags = {
    Name = "load_balancer_c"
  }
}

resource "aws_subnet" "wordpress_a" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "wordpress_a"
  }
}

resource "aws_subnet" "wordpress_b" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3b"

  tags = {
    Name = "wordpress_b"
  }
}

resource "aws_subnet" "wordpress_c" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3c"

  tags = {
    Name = "wordpress_c"
  }
}

resource "aws_subnet" "efs_a" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "efs_a"
  }
}

resource "aws_subnet" "efs_b" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3b"

  tags = {
    Name = "efs_b"
  }
}

resource "aws_subnet" "efs_c" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3c"

  tags = {
    Name = "efs_c"
  }
}

resource "aws_subnet" "database_a" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "database_a"
  }
}

resource "aws_subnet" "database_b" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.7.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3b"

  tags = {
    Name = "database_b"
  }
}

resource "aws_subnet" "database_c" {
  vpc_id                  = aws_vpc.wp_vpc.id
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-3c"

  tags = {
    Name = "database_c"
  }
}
resource "aws_internet_gateway" "wp_igw" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "wp_igw"
  }
}

resource "aws_route_table" "wp_public" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "wp_public"
  }
}

resource "aws_route" "wp_default_route" {
  route_table_id         = aws_route_table.wp_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wp_igw.id
}

resource "aws_route_table_association" "wp_lba_public" {
  subnet_id      = aws_subnet.load_balancer_a.id
  route_table_id = aws_route_table.wp_public.id
}

resource "aws_route_table_association" "wp_lbb_public" {
  subnet_id      = aws_subnet.load_balancer_b.id
  route_table_id = aws_route_table.wp_public.id
}

resource "aws_route_table_association" "wp_lbc_public" {
  subnet_id      = aws_subnet.load_balancer_c.id
  route_table_id = aws_route_table.wp_public.id
}

resource "aws_eip" "wp_nat_a" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

resource "aws_eip" "wp_nat_b" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

resource "aws_eip" "wp_nat_c" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

resource "aws_nat_gateway" "wp_nat_a" {
  allocation_id = aws_eip.wp_nat_a.id
  subnet_id     = aws_subnet.load_balancer_a.id

  tags = {
    Name = "wp_nat_a"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.wp_igw]
}

resource "aws_nat_gateway" "wp_nat_b" {
  allocation_id = aws_eip.wp_nat_b.id
  subnet_id     = aws_subnet.load_balancer_b.id

  tags = {
    Name = "wp_nat_b"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.wp_igw]
}

resource "aws_nat_gateway" "wp_nat_c" {
  allocation_id = aws_eip.wp_nat_c.id
  subnet_id     = aws_subnet.load_balancer_c.id

  tags = {
    Name = "wp_nat_c"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.wp_igw]
}

resource "aws_route_table" "wp_private_a" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "wp_private_a"
  }
}

resource "aws_route_table" "wp_private_b" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "wp_private_b"
  }
}

resource "aws_route_table" "wp_private_c" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "wp_private_c"
  }
}

resource "aws_route" "wp_wordpress_a_internet_route" {
  route_table_id         = aws_route_table.wp_private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.wp_nat_a.id
}

resource "aws_route" "wp_wordpress_b_internet_route" {
  route_table_id         = aws_route_table.wp_private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.wp_nat_b.id
}

resource "aws_route" "wp_wordpress_c_internet_route" {
  route_table_id         = aws_route_table.wp_private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.wp_nat_c.id
}

resource "aws_route_table_association" "wp_wordpress_a_wp_private_a" {
  subnet_id      = aws_subnet.wordpress_a.id
  route_table_id = aws_route_table.wp_private_a.id
}

resource "aws_route_table_association" "wp_wordpress_b_wp_private_b" {
  subnet_id      = aws_subnet.wordpress_b.id
  route_table_id = aws_route_table.wp_private_b.id
}

resource "aws_route_table_association" "wp_wordpress_c_wp_private_c" {
  subnet_id      = aws_subnet.wordpress_c.id
  route_table_id = aws_route_table.wp_private_c.id
}