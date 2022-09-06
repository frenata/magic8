packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
source "amazon-ebs" "ubu-ami" {
  ami_name      = "learn-packer-linux-aws {{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "docker" "ubu-img" {
  image = "golang:bullseye"
  commit = true
  changes = [
    "WORKDIR /tmp/magic",
    "EXPOSE 8080",
    "CMD go run /tmp/magic/main.go;",
    "ENTRYPOINT [\"\"]"
  ]
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubu-ami",
    "source.docker.ubu-img"
  ]
  provisioner "shell" {
    inline = ["mkdir /tmp/magic"]
  }

  provisioner "file" {
    source = "main.go"
    destination = "/tmp/magic/main.go"
  }

  provisioner "file" {
    only = ["amazon-ebs.ubu-ami"]
    source = "magic.service"
    destination = "/tmp/magic/magic.service"
  }

  provisioner "shell" {
    only = ["amazon-ebs.ubu-ami"]
    inline = [
      "sudo apt update",
      "sudo apt install -y golang",
      "sudo cp /tmp/magic/magic.service /etc/systemd/system/magic.service",
      "sudo mkdir /opt/magic",
      "sudo cp /tmp/magic/main.go /opt/magic/main.go",
      "sudo systemctl enable magic.service"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      only = ["docker.ubu-img"]
      repository = "frenata/magic"
      tags = ["latest"]
    }
  }
}
