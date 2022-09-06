resource "aws_security_group" "magic8_lb_sg" {
  name        = "magic8_lb_sg"
  vpc_id      = aws_vpc.magic.id
  description = "allowed ports for load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_lb" "magic8" {
  name               = "magic8-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.magic8_lb_sg.id]
  subnets            = [aws_subnet.one.id, aws_subnet.two.id]
}

resource "aws_lb_target_group" "magic8_tg" {
  name     = "magic8-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.magic.id
}

resource "aws_lb_listener" "magic8" {
  load_balancer_arn = aws_lb.magic8.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.magic8_tg.arn
  }
}
