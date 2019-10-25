data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["private_subnet_1"]
  }
}

data "aws_subnet" "private_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["private_subnet_2"]
  }
}

data "aws_subnet" "private_subnet_3" {
  filter {
    name   = "tag:Name"
    values = ["private_subnet_3"]
  }
}

data "aws_eks_cluster" "bootifulmicropizza" {
  name = "bootifulmicropizza"
}

resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "jenkins_efs"
  encrypted = true
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    "Name" = "jenkins_efs"
  }
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/var"
    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = 777
    }
  }
}

resource "aws_efs_mount_target" "alpha1" {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  subnet_id      = data.aws_subnet.private_subnet_1.id
  security_groups = [data.aws_eks_cluster.bootifulmicropizza.vpc_config[0].cluster_security_group_id]
}

resource "aws_efs_mount_target" "alpha2" {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  subnet_id      = data.aws_subnet.private_subnet_2.id
  security_groups = [data.aws_eks_cluster.bootifulmicropizza.vpc_config[0].cluster_security_group_id]
}

resource "aws_efs_mount_target" "alpha3" {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  subnet_id      = data.aws_subnet.private_subnet_3.id
  security_groups = [data.aws_eks_cluster.bootifulmicropizza.vpc_config[0].cluster_security_group_id]
}

output "file_system_id" {
  value = aws_efs_file_system.jenkins_efs.id
}

output "access_point_id" {
  value = aws_efs_access_point.test.id
}
