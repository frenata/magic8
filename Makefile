all:
	packer build build.pkr.hcl

dev:
	packer build -only=magic-8-ball.docker.ubu-img build.pkr.hcl

prod:
	packer build -only=magic-8-ball.amazon-ebs.ubu-ami build.pkr.hcl

base:
	packer build base.pkr.hcl
