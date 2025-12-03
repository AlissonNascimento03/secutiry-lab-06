# ❌ VULNERABILIDADES EM COMPUTAÇÃO

# EC2 sem encryption e com configurações inseguras
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  
  # ❌ VULNERABILIDADE: Sem role IAM
  # iam_instance_profile = null
  
  # ❌ VULNERABILIDADE: EBS sem encryption
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    encrypted   = false  # Dados não criptografados!
  }
  
  # ❌ VULNERABILIDADE: IMDSv1 (permite SSRF)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"  # Deveria ser "required" (IMDSv2)
  }
  
  # ❌ VULNERABILIDADE: User data com credenciais
  user_data = <<-EOF
              #!/bin/bash
              echo "root:Password123!" | chpasswd
              echo "export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE" >> /root/.bashrc
              echo "export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" >> /root/.bashrc
              EOF
  
  # ❌ VULNERABILIDADE: Monitoring desabilitado
  monitoring = false
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  tags = {
    Name = "web-server"
  }
}

# ❌ VULNERABILIDADE: EBS volume sem encryption
resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.web.availability_zone
  size              = 100
  encrypted         = false  # Sem encryption!
  
  tags = {
    Name = "data-volume"
  }
}

# ❌ VULNERABILIDADE: Snapshot público
resource "aws_ebs_snapshot" "backup" {
  volume_id = aws_ebs_volume.data.id
  
  tags = {
    Name = "public-snapshot"
  }
}

resource "aws_ebs_snapshot_create_volume_permission" "public" {
  snapshot_id = aws_ebs_snapshot.backup.id
  account_id  = "*"  # Público para todo mundo!
}
