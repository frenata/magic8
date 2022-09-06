packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
source "amazon-ebs" "ubu-ami" {
  ami_name      = "magic8-image-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu-with-go-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      state               = "available"
    }
    most_recent = true
    owners      = ["514698705445"]
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
  name = "magic-8-ball"
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
    post-processor "shell-local" {
      only = ["docker.ubu-img"]
      inline = [
        "docker stop magic8 || true",
        "docker rm magic8 || true",
        "docker run --name magic8 -p 8080:8080 -d frenata/magic:latest"
      ]
    }

    post-processor "manifest" {
      only = ["amazon-ebs.ubu-ami"]
    }
    post-processor "shell-local" {
      only = ["amazon-ebs.ubu-ami"]
      inline = [
        "bash deploy.sh $(jq -r '.builds[-1].artifact_id' packer-manifest.json | cut -d ':' -f2)",
        "rm packer-manifest.json"
      ]
    }
  }
}
