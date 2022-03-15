// Provider specific configs
provider "aws" {
  region = var.aws_region
}

/* data "template_cloudinit_config" "master" {
  gzip          = true
  base64_encode = true

  # get common user_data
  part {
    filename     = "common.cfg"
    content_type = "text/part-handler"
    content      = "${data.template_file.userdata_common.rendered}"
  }

  # get master user_data
  part {
    filename     = "master.cfg"
    content_type = "text/part-handler"
    content      = "${data.template_file.userdata_master.rendered}"
  }
} */

// EC2 Instance Resource for Module
resource "aws_instance" "ec2_instance" {
  count                  = var.ec2_count
  instance_type          = var.instance_type
  ami                    = var.ami_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]
  iam_instance_profile   = aws_iam_instance_profile.terraform_profile.name
  subnet_id              = var.subnet_id
  user_data              = file(var.user_data)
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 50
  }


  tags = {
    Name        = var.instance_name
    Environment = var.environment_tag
    Owner       = "Suresh"
    Project     = "Test"
  }
}

#--------- Security Groups -------------#

resource "aws_security_group" "instance" {
  name        = "instance"
  description = "used for access to the dev instance"


  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Custom TCP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Custom TCP
  ingress {
    from_port   = 8081
    to_port     = 8081
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
    Owner       = "Suresh"
    Project     = "Test"
  }
}

#-------------IAM-------------#
resource "aws_iam_role" "test" {
  name = "test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = var.instance_name
    Environment = "Test"
    Owner       = "Suresh"
    Project     = "Test"
  }
}

resource "aws_iam_instance_profile" "terraform_profile" {
  name = "terraform_profile"
  role = aws_iam_role.test.name
}

resource "aws_iam_role_policy_attachment" "test_attach1" {
  role       = aws_iam_role.test.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "test_attach2" {
  role       = aws_iam_role.test.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}
