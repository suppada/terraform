#!/bin/sh -xv

yum update -y 
yum install jq ansible -y


#ssm agent install
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent

#awscli install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
$PATH='/usr/local/bin'



#Script to add a user to Linux system
username='ansible'
password='ansible123'
if [ $(id -u) -eq 0 ]; then
        #read -p "Enter username : " username
        #read -s -p "Enter password : " password
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "$username exists!"
                exit 1
        else
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                useradd -m -p $pass $username
                [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
                # ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
                # Run me with superuser privileges
                echo '$username       ALL=(ALL)       ALL' >> /etc/sudoers
                sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
                service sshd restart
        fi
else
        echo "Only root may add a user to the system"
        exit 2
fi
