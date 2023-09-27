# provider
provider "aws" {
  profile = "default"
  region  = var.AWS_REGION
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


# Create S3 bucket 
resource "aws_s3_bucket" "s3_demo_asg" {
  bucket = var.bucket_name
  acl    = var.acl_value
}


# create EC2 IAM role
resource "aws_iam_role" "ec2-iam-role" {
  name = "ec2-demo-asg-iam-role"

  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF
}

# attach policies to the role
resource "aws_iam_role_policy_attachment" "ec2roletoaccesss3demoasg" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2-iam-role.name
}

# Create EC2 Instance Profile
resource "aws_iam_instance_profile" "demo_asg_profile" {
  name = "demo_asg_ec2_profile"
  role = aws_iam_role.ec2-iam-role.name
}


# Create pub subnets
resource "aws_subnet" "asg-sub-pub-a" {
  vpc_id                  = var.default_VPC_id
  cidr_block              = var.asg_sub_pub_a_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2a"

  tags = {
    Name = "sub-asg-pub-a"
  }
}

resource "aws_subnet" "asg-sub-pub-b" {
  vpc_id                  = var.default_VPC_id
  cidr_block              = var.asg_sub_pub_b_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2b"

  tags = {
    Name = "sub-asg-pub-b"
  }
}


# Create Security Groups
resource "aws_security_group" "demo_asg_instance" {
  name = "sg_demo_asg_instance"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.demo_asg_lb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.demo_asg_lb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = var.default_VPC_id
}

resource "aws_security_group" "demo_asg_lb" {
  name = "sg_demo_asg_lb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = var.default_VPC_id
}


# Create Launch Config
resource "aws_launch_configuration" "demo_asg" {
  name_prefix          = "terraform-demo-aws-asg"
  image_id             = var.ami
  instance_type        = var.instance_type
  key_name             = var.instance_key
  iam_instance_profile = aws_iam_instance_profile.demo_asg_profile.name
  user_data            = file("user-data.sh")
  security_groups      = [aws_security_group.demo_asg_instance.id]

  lifecycle {
    create_before_destroy = true
  }
}


# Create ASG
resource "aws_autoscaling_group" "demo_asg" {
  name                 = "demo_asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.demo_asg.name
  vpc_zone_identifier  = [aws_subnet.asg-sub-pub-a.id, aws_subnet.asg-sub-pub-b.id]

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "Terraform Demo ASG"
    propagate_at_launch = true
  }
}


# Create ALB
resource "aws_lb" "demo_asg" {
  name               = "alb-demo-asg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo_asg_lb.id]
  subnets            = [aws_subnet.asg-sub-pub-a.id, aws_subnet.asg-sub-pub-b.id]
}

resource "aws_lb_listener" "demo_asg" {
  load_balancer_arn = aws_lb.demo_asg.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_asg_tg.arn
  }
}

resource "aws_lb_target_group" "demo_asg_tg" {
  name     = "tg-demo-asg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.default_VPC_id
}

# Attach ASG to TG
resource "aws_autoscaling_attachment" "demo_asg" {
  autoscaling_group_name = aws_autoscaling_group.demo_asg.id
  lb_target_group_arn    = aws_lb_target_group.demo_asg_tg.arn
}




# terraform apply -destroy

