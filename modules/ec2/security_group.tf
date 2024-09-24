#--------- Security Groups -------------#

resource "aws_security_group" "sg" {
  name        = var.security_group_name
  description = "used for access to the dev instance"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.instance_name
    Environment = var.environment_tag
    Owner       = var.owner
    Project     = var.project
  }
}
