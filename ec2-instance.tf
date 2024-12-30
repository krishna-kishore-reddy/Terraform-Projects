
resource "aws_security_group" "all-traffic" {
    description = "allow all incomming traffic"
    vpc_id = aws_vpc.kishorevpc.id
    tags = {
      Name = "Allow-all-traffic"
    }
  
}

resource "aws_security_group_rule" "alltraffic" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.all-traffic.id

  
}

resource "aws_security_group_rule" "all-traffic" {
    type              = "egress"
    from_port         = 0
    to_port           = 65535
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.all-traffic.id
    
    
  
}

resource "aws_instance" "nginx-server" {
    ami = "ami-0f935a2ecd3a7bd5c"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.publicsubnet.id
    vpc_security_group_ids = [aws_security_group.all-traffic.id]

    root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Kishore-Nginx-Server"
  }
  
}

resource "aws_instance" "httpd-server" {
    ami = "ami-0f935a2ecd3a7bd5c"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.publicsubnet.id
    vpc_security_group_ids = [aws_security_group.all-traffic.id]

    root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Kishore-httpd-Server"
  }
  
}
