all:
	cd build && packer build build.pkr.hcl

dev:
	cd build && packer build -only=magic-8-ball.docker.ubu-img build.pkr.hcl

prod:
	cd build && packer build -only=magic-8-ball.amazon-ebs.ubu-ami build.pkr.hcl

base:
	cd build && packer build base.pkr.hcl

init:
	cd build && packer init
	cd terraform && terraform init
