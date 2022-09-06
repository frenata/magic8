# POC Immutable Infra

This is a proof-of-concept of using packer to specify immutable infrastructure on AWS. The intent is to demonstrate how to get packer, autoscaling EC2 groups, local dev environments, CodeDeploy, and terraform all working together to absolutely minimize the need for manual effort in maintaining both prod and dev environments for a simple application.

## Explanation

How to try this POC out yourself:

  1. install terraform, packer, the aws cli, and jq
  2. configure your default AWS region (via `aws configure`) as us-west-1 (this region assumption is hard-coded in several places)
  3. initialize the infrastructure: `cd terraform && terraform apply` (at this point you'll have an unhealthy target group)
  4. (parallelizable with 3), start building AMIs, first the *base* AMI, then the *application* AMI on top of that. A post-processing step of the application build should update the AMI being used by the autoscaling group and re-deploy instances.
  5. Query the generated URL for your load balancer, see the output from the application.
  6. Try modifying the application (in `src`) to behave differently, and rebuild the application AMI (try `make prod` for a shortcut)

### Base

The base build crafts an AMI that has all the major underlying dependencies that the application needs to run. In this case that's just `go`, but it could do a host of other things like `nginx`, harden various other areas of the system, etc.

### Prod

The main production build starts from the base build (making builds much faster since everything is already prepped), and then focuses on just getting our application into the image and configuring it to run on startup (via systemd).

### Dev

Finally, in the exact same build script as we use for prod, there's a development environment specified (via docker) that rebuilds and restarts everything a developer might need to interact with their local system. Again to save 'boot speed', it's likely that you'd split this into a base image (venv, etc) and a app image.

## TODO

  * specify a codedeploy application so that the prod artifact is built and deployed on pushes
