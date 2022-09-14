all:
	cd build && packer build build.pkr.hcl

dev:
	cd build && packer build -only=magic-8-ball.docker.ubu-img build.pkr.hcl

prod:
	cd infra && terraform apply
	cd build && packer build -only=magic-8-ball.amazon-ebs.ubu-ami build.pkr.hcl

base:
	cd build && packer build base.pkr.hcl

init:
	cd build && packer init base.pkr.hcl && packer init build.pkr.hcl
	cd infra && terraform init
