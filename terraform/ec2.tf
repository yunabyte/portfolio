resource "aws_launch_template" "fastapi_lt" {
  name_prefix   = "fastapi-"
  image_id      = "ami-027b635eef01a0325"
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker
    usermod -a -G docker ec2-user

    # CodeDeploy Agent 설치
    yum install -y ruby wget
    cd /home/ec2-user
    wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto
    systemctl start codedeploy-agent
    systemctl enable codedeploy-agent
  EOF
  )
  
    tag_specifications {
        resource_type = "instance"

        tags = {
        Name = "backend-instance"
        }
    }   

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.private_a.id
    security_groups             = [aws_security_group.ec2_sg.id]
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "fastapi-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "backend_alb" {
  name               = "fastapi-alb"
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                      = "fastapi-asg"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.fastapi_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]

  tag {
    key                 = "Name"
    value               = "fastapi-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}