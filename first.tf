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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfPiHRf2sNxPlbwT2C/RwaT7x9W/44qfyJdBG0kilHi+opHd1iq7vgxobg4dQGB0d85QJZvlG4/b4ilKEreiuTiedx7+7NYIUpMH5XDYziDX9t/rLQEuhIU9ggQ7/JtW3Kt4u3JvrJDzt0cyf/J4WVPvdEt/I1NLS21BAhYiKNbwNwfR0kZ5Xo1vGuj50fwCYUU35VQF5wyUV61Y3LkFRct6h2UpGoAVOH6pU8ge9+vOYitKNEBXWr+niynCnu7PqRYQa2hKAFSkXoNWsIpYeWTbBzqWnKhkyC+ybyKUUnZTPZ4hlplarT0GWlQjF/R8Mr4z5NXUV1H2y4h75rpn2LneUZprRIXHm5NxlIQFBzjUnxk9CZ0jIhS9HOJawI1u1xjHtO12nWuaHcza64Qxm7mjpovnJhnSUKaMbXm7R2lFpqWUPAlHydKdlSaDahrp83aC2D90tRMQJz3qQqMfJuB6NOeAqKGKLlPQ7CxFuSRXhlSMdnS90yRl0Qp7IrLNtBFggzSOQ3rQ3AzKRbl4DWwHPMpoUBIUoJaL89XXNyGnxRkW9BoZhkkQ9HEX0l+LDJ0Fh+C4FL4+hxKkHFj9SKhO6f6FB5xd+m5KetiEPHxuxFPK8+xGAUwfOZDASR+HljyVC3UrQUHr4zLKeKjYT2Tk4Wtfy30iKEYes8yEjk5w== danish@danish-PORTEGE-Z30-A"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh traffic traffic"
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0./0"]
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
