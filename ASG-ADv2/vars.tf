variable "AWS_REGION" {
  default = "us-east-2"
}

variable "bucket_name" {
  description = "S3 bucket nmae"
  default     = "s3-demo-asg-counter-app-repo-01"
}

variable "acl_value" {
  description = "S3 acl"
  default     = "private"
}

variable "default_VPC_id" {
  description = "default VPC ID"
  default     = "vpc-07b2af77184cf668e"
}

variable "asg_sub_pub_a_cidr" {
  description = "CIDR for Public Subnet A"
  default     = "172.31.64.0/28"
}

variable "asg_sub_pub_b_cidr" {
  description = "CIDR for Public Subnet B"
  default     = "172.31.65.0/28"
}

variable "ami" {
  description = "amazon machine image value"
  default     = "ami-0d50e9ae42eead5cd"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "instance_key" {
  description = "Instance access key"
  default     = "Terraform01"
}


