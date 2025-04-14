resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "vpc-via-terraform"
    }
}
#--------------------------------------------------------------------------------------------
resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.regiao
    map_public_ip_on_launch = true
    cidr_block = ["10.0.0.0/16"]
    tags = {
        Name = "subnet-via-terraform"
    }
}
#--------------------------------------------------------------------------------------------
resource "aws_route_table" "routetable" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = ["0.0.0.0/0"]
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "routetable-via-terraform"
    }
}
#--------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    
    tags = {
        Name = "igw-via-terraform"
    }
    
}
#--------------------------------------------------------------------------------------------
resource "aws_route_table_association" "routetableassociation" {
    route_table_id = aws_route_table.routetable.id
    subnet_id = aws_subnet.subnet.id
}
#--------------------------------------------------------------------------------------------
resource "aws_security_group" "alb-sg" {
    vpc_id = aws_vpc.vpc.id

    ingress {
        to_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }


    egress  {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = "0.0.0.0/0"

    }
}
#--------------------------------------------------------------------------------------------
resource "aws_security_group" "ec2-alb" {
    vpc_id = aws_vpc.vpc.id

    ingress = {
        to_port = 80 
        from_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]         
    }

    egress = {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/16"]
    }
}
#--------------------------------------------------------------------------------------------
resource "aws_launch_template" "template" {
    name_prefix = "lt-web"
    image_id = data.aws_ami.amazon_linux.id
    instance_type = var.tipo

    network_interfaces {
      security_groups = [aws_security_group.ec2-alb.id]
      associate_public_ip_address = true
    }

      user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
              EOF
      )
}
#--------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "asg" {
    desired_capacity = 2
    max_size = 4
    min_size = 2
    vpc_zone_identifier = aws_subnet.subnet.id

    launch_template {
      id = aws_launch_template.template.id
      version = "$Latest"
    }

    target_group_arns = [ aws_lb_target_group.web_tg ]
    health_check_type = "ELB"

}
#--------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "web_tg" {
    name     = "web-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.vpc.id
    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200"
  }
}
#--------------------------------------------------------------------------------------------
resource "aws_lb" "lb" {
    name = "web-alb"
    load_balancer_type = "application"
    subnets = aws_subnet.subnet.id
    security_groups = [ aws_security_group.alb-sg.id ]
}
#--------------------------------------------------------------------------------------------
resource "aws_lb_listener" "lb-listener" {
    load_balancer_arn = aws_lb.lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.web_tg.arn
    }
}
#--------------------------------------------------------------------------------------------
