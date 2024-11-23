# outputs.tf

# ALB Outputs
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.alb.arn
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.alb.zone_id
}

# Target Group Outputs
output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.alb_tg.arn
}

output "target_group_name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.alb_tg.name
}

# Auto Scaling Group Outputs
output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.arn
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

# VPC and Subnet Information
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.tf-vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value = {
    subnet_1 = aws_subnet.tf-subnet-1.id
    subnet_2 = aws_subnet.tf-subnet-2.id
  }
}