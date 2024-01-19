provider "aws" {
  region = "us-east-1"
} 

/*
data "aws_ami" "latestami" {
  owners = ["amazon"]
  most_recent = "true"
  }
  */

/* --------- VPC --------- */
resource "aws_vpc" "demovpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Demo VPC"
  }
}

/* --------- Subnets --------- */

/* --------- Private Subnet --------- */

resource "aws_subnet" "privatesubnetA" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = "10.0.16.0/20" #4096 addresses
  availability_zone = "us-east-1a"

  tags = {
    Name = "privatesubnetA"
  }
}

resource "aws_subnet" "privatesubnetB" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = "10.0.32.0/20" #4096 addresses
  availability_zone = "us-east-1b"

  tags = {
    Name = "privatesubnetB"
  }
}


/* --------- Public Subnet --------- */

resource "aws_subnet" "publicsubnetA" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "10.0.0.0/24" #256 addresses
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnetA"
  }
}

resource "aws_subnet" "publicsubnetB" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "10.0.1.0/24" # 256 addresses
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnetB"
  }
}

/* ---- Internet gateway for the public subnet ---- */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demovpc.id
  tags = {
    Name = "igw"
  }
}

/* ---- Public Route table ---- */

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demovpc.id
  # Adding route out to Internet g/W
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

/* ---- Route table association with public Subnet---- */

resource "aws_route_table_association" "public_rt_assocA" {
  subnet_id      = aws_subnet.publicsubnetA.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "public_rt_assocB" {
  subnet_id      = aws_subnet.publicsubnetB.id
  route_table_id = aws_route_table.public_rt.id

}

/* ---- ENI ---- */
/*
resource "aws_network_interface" "publiceni" {
  subnet_id       = aws_subnet.publicsubnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.LB_sg.id]

  }

resource "aws_network_interface" "privateeni" {
  subnet_id       = aws_subnet.privatesubnet.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.ec2_sg.id]

  } */

/* ---- EIP ---- */

/*
resource "aws_eip" "publiceip" {
  #domain = "vpc"
  network_interface = aws_network_interface.publiceni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.igw]
} */

resource "aws_eip" "NAT_eip_A" {
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "eip for NAT A"
  }
}

resource "aws_nat_gateway" "NATgw_A" {
  allocation_id = aws_eip.NAT_eip_A.id
  subnet_id     = aws_subnet.publicsubnetA.id

  tags = {
    Name = "NATgw_A"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "NAT_eip_B" {
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "eip for NAT B"
  }
}

resource "aws_nat_gateway" "NATgw_B" {
  allocation_id = aws_eip.NAT_eip_B.id
  subnet_id     = aws_subnet.publicsubnetB.id

  tags = {
    Name = "NATgw_B"
  }

  depends_on = [aws_internet_gateway.igw]
}
/* ---- Private Route table ---- */

resource "aws_route_table" "PrivatetRTA" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw_A.id
  }

  tags = {
    Name = "PrivatetRTA"
  }
}

resource "aws_route_table_association" "private_rt_assocA" {
  subnet_id      = aws_subnet.privatesubnetA.id
  route_table_id = aws_route_table.PrivatetRTA.id
}

resource "aws_route_table" "PrivatetRTB" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw_B.id
  }

  tags = {
    Name = "PrivatetRTB"
  }
}

resource "aws_route_table_association" "private_rt_assocB" {
  subnet_id      = aws_subnet.privatesubnetB.id
  route_table_id = aws_route_table.PrivatetRTB.id
}

/* ---- ALB ---- */

resource "aws_lb" "demoalb" {
  name               = "demoalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_sg.id]
  subnets            = [aws_subnet.publicsubnetA.id, aws_subnet.publicsubnetB.id]
  depends_on         = [aws_internet_gateway.igw]
}

resource "aws_lb_target_group" "demoalb_tg" {
  name     = "demo-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demovpc.id
}

resource "aws_lb_listener" "demo_front_end" {
  load_balancer_arn = aws_lb.demoalb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demoalb_tg.arn
  }
}

/* ------- launch configuration and ASG ------- */

resource "aws_launch_configuration" "demo_config" {
  name     = "demo_config"
  image_id = "ami-0df435f331839b2d6"
  #image_id               = data.aws_ami.latestami.id
  instance_type        = var.instance_type #"t2.micro"
  key_name             = "Mrini-Nov 2023"
  security_groups      = [aws_security_group.ec2_sg.id]
  iam_instance_profile = "ec2_profile"

  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd  
    
  EOF


  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "52"
    iops        = "1500"
  }

  # user_data = file("apache.sh")

  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_autoscaling_group" "demo_asg" {
  name                = "terraform-asg-demo"
  vpc_zone_identifier = [aws_subnet.privatesubnetA.id, aws_subnet.privatesubnetB.id]
  min_size            = 1
  max_size            = 5
  desired_capacity    = 3
  force_delete        = true

  launch_configuration = aws_launch_configuration.demo_config.name

  #count = demo_asg.desired_capacity

  tag {
    key                 = "Name"
    value               = "private_app"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.demoalb_tg.arn]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "ansible_master" {
  ami                    = var.ami_id            # Specify your desired Amazon Linux 2 AMI
  instance_type          = var.instance_type     # Specify your desired instance type
  key_name               = var.instance_key_name # Specify your key pair name
  subnet_id              = aws_subnet.publicsubnetA.id
  vpc_security_group_ids = [aws_security_group.ALB_sg.id]
  #iam_instance_profile   = "ec2_profile"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3
              sudo yum install -y ansible
              EOF

  tags = {
    Name = "ansible_master"
  }

  /*provisioner "local-exec" {
    command = "echo ${aws_instance.ansible_master.public_ip} >> /etc/hosts"
  } */
}


/* ---- Load balancer SG ---- */

resource "aws_security_group" "ALB_sg" {
  name        = "ALB_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demovpc.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB_sg"
  }
}

/* ---- EC2 SG ---- */

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow http request from LB"
  vpc_id      = aws_vpc.demovpc.id
  #security_group_id = aws_security_group.LB_sg.id
  #cidr_ipv4         = aws_vpc.demovpc.cidr_block


  ingress {
    description = "Allow http request from LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] #"aws_security_group.ALB_sg.id"
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]

  }

  tags = {
    Name = "ec2_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* ---- ec2 instance profile role ---- */

resource "aws_iam_instance_profile" "demo-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.demo-iam-role.name
}
resource "aws_iam_role" "demo-iam-role" {
  name               = "dev-ssm-role"
  description        = "role for the management purpose"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}
resource "aws_iam_role_policy_attachment" "demo-ssm-policy" {
  role       = aws_iam_role.demo-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
