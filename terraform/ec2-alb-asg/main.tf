provider "aws" {
  region = var.region
}


### Provision VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block = var.vpc_cidr_block

  ### enable DNS hostnames for the VPC
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main_vpc"
  }
}

# Create subnets in different AZs
resource "aws_subnet" "tf-subnet-1" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 1)  # e.g., if vpc is 10.0.0.0/16, this will be 10.0.1.0/24
  availability_zone = "${var.region}a"                       # First AZ in the region

  tags = {
    Name = "tf-subnet-1"
  }
}

resource "aws_subnet" "tf-subnet-2" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 2)  # e.g., if vpc is 10.0.0.0/16, this will be 10.0.2.0/24
  availability_zone = "${var.region}b"                       # Second AZ in the region

  tags = {
    Name = "tf-subnet-2"
  }
}


# Internet Gateway(and route tables) for internet connectivity in the subnet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "main"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main"
  }
}

# Route Table Associations
resource "aws_route_table_association" "subnet-1" {
  subnet_id      = aws_subnet.tf-subnet-1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-2" {
  subnet_id      = aws_subnet.tf-subnet-2.id
  route_table_id = aws_route_table.main.id
}

## Security Groups 

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "AWS ALB Security Group"
  vpc_id      = aws_vpc.tf-vpc.id

  // Inbound Rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] ## allow HTTP traffic from Load Balancer
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  //Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.tf-subnet-1.id, aws_subnet.tf-subnet-2.id]
}


### Instance Target Group
resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf-vpc.id

   health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    timeout             = 5
    path                = "/"  # Adjust this to match your app's health check endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    unhealthy_threshold = 2
  }
}


## ALB Listener 
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  ## Forward Action
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}


resource "aws_launch_template" "ec2_template" {
  name_prefix =          "ec2_template"
  description   = "EC2 launch template for Auto Scaling Group"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  ## configure with ec2 security groups
  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
  }

  user_data = base64encode(file("main.sh"))
}


resource "aws_autoscaling_group" "asg" {
  name     = "asg"
  min_size = 1
  max_size = 3
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.tf-subnet-1.id, aws_subnet.tf-subnet-2.id]
 
  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "ASG"
    value               = "example-asg-instance"
    propagate_at_launch = true
  }
}


## Creating Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

## CloudWatch alarms for scale up and scale down

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  evaluation_periods  = 2
  threshold           = 30 ## if >= 50% CPU utilization, then scale up
  statistic           = "Average"
  period              = 120
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = "scale_down_alarm"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  comparison_operator = "LessThanThreshold"
  metric_name = "CPUUtilization"
  evaluation_periods = 2
  period = 120
  statistic = "Average"
  threshold = 10
namespace = "AWS/EC2"
   dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}