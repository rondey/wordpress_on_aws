resource "aws_efs_file_system" "wp_efs" {
  encrypted = true

  tags = {
    Name = "wp_efs"
  }
}

resource "aws_efs_mount_target" "wp_efs_target_a" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = aws_subnet.efs_a.id
  security_groups = [aws_security_group.wp_efs_sg.id]
}

resource "aws_efs_mount_target" "wp_efs_target_b" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = aws_subnet.efs_b.id
  security_groups = [aws_security_group.wp_efs_sg.id]
}

resource "aws_efs_mount_target" "wp_efs_target_c" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = aws_subnet.efs_c.id
  security_groups = [aws_security_group.wp_efs_sg.id]
}

resource "aws_efs_access_point" "wp_efs_access" {
  file_system_id = aws_efs_file_system.wp_efs.id

  posix_user {
    uid = "1000"
    gid = "1000"
  }

  root_directory {
    creation_info {
      owner_uid   = "1000"
      owner_gid   = "1000"
      permissions = "0777"
    }

    path = "/wordpress_data"
  }
}