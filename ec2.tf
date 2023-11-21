# Author    : Ranjit Kumar Swain
# Web       : www.ranjitswain.com
# YouTube   : https://www.youtube.com/c/ranjitswain
# GitHub    : https://github.com/ranjit4github
########################################################

resource "aws_instance" "web" {
  ami           = "ami-02a2af70a66af6dfb"
  instance_type = "t2.micro"
  key_name = "test-key"
  subnet_id = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
  count = 2
  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install docker -y
  sudo usermod -aG docker $USER
  sudo usermod -a -G docker ec2-user
  sudo systemctl enable docker.service
  sudo systemctl start docker.service
  sudo docker run -d -p 80:80 nginx:latest
  EOF
  tags = {
    Name = "WebServer-${count.index + 1}"
  }

  provisioner "file" {
    source = "/root/aws_3tier_architecture_terraform/test-key.pem"
    destination = "/home/ec2-user/test-key.pem"
  
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("/root/aws_3tier_architecture_terraform/test-key.pem")}"
    }  
  }
}

resource "aws_instance" "db" {
  ami           = "ami-02a2af70a66af6dfb"
  instance_type = "t2.micro"
  key_name = "test-key"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_tls_db.id]

  tags = {
    Name = "DB Server"
  }
}
