// EC2 Instance Resource for Module
resource "aws_instance" "ec2_instance" {
  count                  = var.ec2_count
  instance_type          = var.instance_type
  ami                    = var.ami_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  subnet_id              = var.subnet_id
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 50
  }

  tags = {
    Name        = var.instance_name
    Environment = var.environment_tag
    Owner       = var.owner
    Project     = var.project
  }
}