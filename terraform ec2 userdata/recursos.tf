resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "VPC-VIA TERRAFORM"
    }
}

#------------------------------------------------------------------

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    availability_zone = var.subnet-regiao
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
}

#------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "IGW"
    }
}

#------------------------------------------------------------------

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }    

    tags = {
        Name = "routetable-terraform"
    } 
}

#------------------------------------------------------------------

resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.rt.id
}

#------------------------------------------------------------------

resource "aws_security_group" "sg" {
    name = "web-sg"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


    tags = {
      Name = "terraform-sg"
    }


}

#------------------------------------------------------------------

resource "aws_instance" "webserver" {
    ami = var.ami_id
    subnet_id = aws_subnet.public.id
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sg.id]


    
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd 
                echo "<h1>Servidor Web via terraform!</h1>" > /var/www/html/index.html
                systemctl start httpd
                systemctl enable http
                EOF
    
    tags = {
      Name = "terraform-web"
    }
}

#------------------------------------------------------------------





