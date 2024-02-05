terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
        }
    }

    required_version = ">= 1.2.0"
}
provider "aws" {
    region = "ap-south-1"  # Change this to the desired AWS region
    profile = "spc-dev"
}

resource "aws_instance" "ec2_instance" {
    count         = 4
    ami           = "ami-0818919f15d5129fe"  # Replace with the desired AMI ID
    instance_type = "t2.micro"
    key_name      = "spc-dev-ec2-instance"  # Replace with your key pair name
    associate_public_ip_address = true  # Set this to false if you do not want a public IP

    user_data = <<EOF
#!/bin/bash
echo "Copying the SSH Key to the server"
echo -e "$(cat /Users/kartikshriwansh/Documents/GitHub/kubespray-infra/terraform-ec2/spc-dev-ec2-instance.pub)"  >> /home/ubuntu/.ssh/authorized_keys
EOF
    tags = {
        Name = "spc-ec2-instance-${count.index + 1}"
    }
}

output "instance_info" {
    value = {
        for instance in aws_instance.ec2_instance :
        instance.id => {
        private_ip    = instance.private_ip
        public_ip     = instance.public_ip
        key_name      = instance.key_name
        instance_type = instance.instance_type
        }
    }
}
