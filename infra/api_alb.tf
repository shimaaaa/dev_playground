resource "aws_security_group" "api_alb" {
  name        = "${local.app_name}-api-alb"
  description = "${local.app_name} alb rule based routing"
  vpc_id      = aws_vpc.this.id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.app_name}-api-alb"
  }
}

resource "aws_security_group_rule" "api_alb_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.api_alb.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "api_alb_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.api_alb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "api" {
  name               = "${local.app_name}-api-alb"
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.api_alb.id
  ]
  subnets = [
    for k, v in local.public_subnets :
    aws_subnet.public[k].id
  ]
}

resource "aws_lb_listener" "api_http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_http.arn
  }
}

resource "aws_lb_target_group" "api_http" {
  name        = "${local.app_name}-http-targetgroup"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/ping"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}
