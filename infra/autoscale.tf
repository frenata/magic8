resource "aws_security_group" "magic8_sg" {
  name        = "magic8_sg"
  vpc_id      = aws_vpc.magic.id
  description = "allowed ports for instances"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_launch_template" "magic8" {
  image_id = "ami-0c033eb565588ae0"
  name     = "magic8-lt"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 4
    }
  }
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
  }
  vpc_security_group_ids = [aws_security_group.magic8_sg.id]
}

resource "aws_autoscaling_group" "magic8" {
  name               = "magic8-auto"
  max_size           = 2
  min_size           = 1
  desired_capacity   = 2
  health_check_type  = "ELB"
  availability_zones = ["us-west-1a", "us-west-1b", "us-west-1c", "us-west-1d"]
  launch_template {
    name    = aws_launch_template.magic8.name
    version = "$Default"
  }
}
