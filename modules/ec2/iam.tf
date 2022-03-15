#-------------IAM-------------#
resource "aws_iam_role" "devops" {
  name = "devops"

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
    Environment = "devops"
    Owner       = "Suresh"
    Project     = "devops"
  }
}

resource "aws_iam_instance_profile" "web" {
  name = "web"
  role = aws_iam_role.devops.name
}

resource "aws_iam_role_policy_attachment" "devops_attach1" {
  role       = aws_iam_role.devops.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "devops_attach2" {
  role       = aws_iam_role.devops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "tf_policy" {
  name = "tf_policy"
  role = aws_iam_role.devops.id

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