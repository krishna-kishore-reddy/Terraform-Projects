terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_vpc" "kishorevpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "tableau-VPC"
    }
  
}

resource "aws_subnet" "privatesubnet" {
    vpc_id = aws_vpc.kishorevpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
      Name = "private"
    }
}

resource "aws_subnet" "publicsubnet" {
    vpc_id = aws_vpc.kishorevpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1b"
    map_public_ip_on_launch = "true"
    tags = {
      Name = "public-1"
    }
}

resource "aws_subnet" "publicsubnet1" {
    vpc_id = aws_vpc.kishorevpc.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-southeast-1a"
    tags = {
      Name = "public-2"
    }
}


resource "aws_internet_gateway" "kishorevpc-IGW" {
    vpc_id = aws_vpc.kishorevpc.id 
    tags = {
      Name = "main"
    }
  
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.kishorevpc.id

  tags = {
    Name = "private-rt"
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kishorevpc.id

  tags = {
    Name = "public-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kishorevpc-IGW.id
  }

}


resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.privatesubnet.id
    route_table_id = aws_route_table.private.id
  
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.publicsubnet.id
    route_table_id = aws_route_table.public.id
  
}

resource "aws_lb_target_group" "nginx-tg" {
  name     = "tf-nginx-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kishorevpc.id
  
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.nginx-tg.arn
  target_id        = aws_instance.nginx-server.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "test1" {
  target_group_arn = aws_lb_target_group.nginx-tg.arn
  target_id        = aws_instance.httpd-server.id
  port             = 80
}


resource "aws_lb" "nginx-lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.all-traffic.id]
  subnets = [ aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet.id ]
  
  
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}
