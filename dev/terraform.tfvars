ec2_count     = "2"
ami_id        = "ami-0b0af3577fe5e3532"
instance_type = "t2.micro"
key_name      = "suresh"
instance_name = "jenkins-node"
user_data     = "./user-ansible.sh"
aws_region    = "us-east-1"
subnet_id     = "subnet-06909708"