provider "aws" {
  region     = "eu-west-1"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_instance" "first" {
  ami           = "ami-09f0b8b3e41191524"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  key_name = "deployer-key"

  provisioner "remote-exec" {

      inline = [
            "sudo apt-get update",
            "sudo apt-get install python -y",
            ]
       connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = "${file("~/.ssh/id_rsa")}"
      }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.first.public_ip},' -u ubuntu  --private-key '~/.ssh/id_rsa' playbook.yml" 
  }    
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDdJwWY5sBMj8wFnspT3xeTlCp+tcC3YTHAZzyiIU/Uyg+Wza9nSgEq27boNkdezTwwGy5wRAk/+8gVEvSZCucHMjtzHDnBT8nM4EwVq/hBszitUGu6w4ThkHehIuh8s65GuGfmG0Mb0Ycj9NyqOjBNGmPMUwePDpmri3K7LBGyy9iUDDiNr/Dw1z3w/vsVxlwVDcY7YQhYLdlrjfeT8PI+L+ulJcwwBEJ7k8wL/KirNNEIMG1CwTx5QUZZhKWJ4DgT0oPEzbnI1BlwIjntEg+mZdZCm1+3Ii8+9ffZh6LGPGLrVU9APg98Hl0ohkOTvL3N3ZAOVa+QyMNpIQy7vCx ansible-generated on localhost.localdomain"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh traffic traffic"
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["143.65.196.4/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["143.65.196.4/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "first" {
	value = "${aws_instance.first.public_ip}"
}
