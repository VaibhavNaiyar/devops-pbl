# VLE 6 - E-commerce: fix deployment failures, manual setup and release downtime
# Solution: IaC (Terraform) + immutable launch templates + ALB health checks
#           + Auto Scaling Group rolling "instance refresh" (min 100% healthy) + CloudWatch alarms
terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.region }

data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------------- Security groups ----------------
resource "aws_security_group" "alb" {
  name   = "${var.project}-alb-sg"
  vpc_id = data.aws_vpc.default.id
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
}

resource "aws_security_group" "app" {
  name   = "${var.project}-app-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    description     = "Only the ALB may reach the app"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- IAM: SSM access instead of SSH, CloudWatch agent ----------------
resource "aws_iam_role" "ec2" {
  name = "${var.project}-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "cw" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-profile"
  role = aws_iam_role.ec2.name
}

# ---------------- Launch template (automated server setup) ----------------
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project}-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  iam_instance_profile { arn = aws_iam_instance_profile.ec2.arn }
  vpc_security_group_ids = [aws_security_group.app.id]
  metadata_options { http_tokens = "required" }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    image    = var.app_image
    version  = var.app_version
    app_port = var.app_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project}-app", Version = var.app_version }
  }
}

# ---------------- Load balancer ----------------
resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app" {
  name                 = "${var.project}-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.default.id
  deregistration_delay = 30 # connection draining
  health_check {
    path                = var.health_path
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ---------------- Auto Scaling Group with rolling, zero-downtime refresh ----------------
resource "aws_autoscaling_group" "app" {
  name                      = "${var.project}-asg"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = data.aws_subnets.default.ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB" # replace instances that fail app health checks (self-healing)
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100 # launch new before terminating old -> no downtime
      max_healthy_percentage = 200
      instance_warmup        = 90
      auto_rollback          = true # failed release rolls back automatically
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.project}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification { predefined_metric_type = "ASGAverageCPUUtilization" }
    target_value = 60
  }
}

# ---------------- Monitoring ----------------
resource "aws_cloudwatch_metric_alarm" "unhealthy" {
  alarm_name          = "${var.project}-unhealthy-hosts"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "errors_5xx" {
  alarm_name          = "${var.project}-5xx"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = { LoadBalancer = aws_lb.this.arn_suffix }
}
