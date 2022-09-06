resource "aws_security_group" "magic8_sg" {
  name        = "magic8_sg"
  vpc_id      = aws_vpc.magic.id
  description = "allowed ports for instances"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.magic8_lb_sg.id]
  }
}

resource "aws_launch_template" "magic8" {
  image_id = "ami-0a1069756c2859f0b" # NOTE a base ubuntu AMI, will be replaced ASAP with an app AMI
  name     = "magic8-lt"
  key_name = "magic8" # NOTE Assumes you've already created this keypair

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.magic8_sg.id]
  }

  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "aws_autoscaling_group" "magic8" {
  name                = "magic8-auto"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 2
  health_check_type   = "ELB"
  vpc_zone_identifier = [aws_subnet.one.id, aws_subnet.two.id]
  target_group_arns   = [aws_lb_target_group.magic8_tg.arn]
  launch_template {
    name    = aws_launch_template.magic8.name
    version = "$Default"
  }
}
