# POC Immutable Infra

This is a proof-of-concept of using packer to specify immutable infrastructure on AWS. The intent is to demonstrate how to get packer, autoscaling EC2 groups, local dev environments, CodeDeploy, and terraform all working together to absolutely minimize the need for manual effort in maintaining both prod and dev environments for a simple application.

## Base

The base build crafts an AMI that has all the major underlying dependencies that the application needs to run. In this case that's just `go`, but it could do a host of other things like `nginx`, harden various other areas of the system, etc.

## Prod

The main production build starts from the base build (making builds much faster since everything is already prepped), and then focuses on just getting our application into the image and configuring it to run on startup (via systemd).

## Dev

Finally, in the exact same build script as we use for prod, there's a development environment specified (via docker) that rebuilds and restarts everything a developer might need to interact with their local system. Again to save 'boot speed', it's likely that you'd split this into a base image (venv, etc) and a app image.

## TODO

  * specify the necessary infra as code
    * launch template
    * autoscaling group
    * security groups
    * load balancer and target group
  * specify a codedeploy application so that the prod artifact is built and deployed on pushes
