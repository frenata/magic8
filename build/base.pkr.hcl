packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
source "amazon-ebs" "ubu-ami" {
  ami_name      = "ubuntu-with-go-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami = "ami-0c033eb565588ae0e" # Official Ubunutu 22.04 "jammy"
  ssh_username = "ubuntu"
}

build {
  name = "make-ubuntu-with-go"
  sources = [
    "source.amazon-ebs.ubu-ami",
  ]

  provisioner "shell" {
    only = ["amazon-ebs.ubu-ami"]
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt update",
      "sleep 5",
      "sudo apt install -y golang-go"
    ]
  }

}
