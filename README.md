# Phrasee Application Task

## Purpose
This repository provides the terraform content for the creation of the resources requested in the task and as below:
* S3 Bucket which contains the index.hmtl web content.
* A private EC2 Instance running an NGINX Docker container acting as a web server.
* A public EC2 Instance acting as a proxy for HTTP and SSH traffic to the private web server.
* CloudWatch Dashboard for monitoring the private EC2 Instance and NGINX proceses.

## Prerequisites
* A role/user with sufficient privileges to deploy the services into the account used.

## Usage
For the purposes of the test placeholders have been used where the value may need to be substituted to align with Phrasees Cloud Estate.

The repository can be ran by cd into the repository base and then performing the appropriate commands shown below.

Initialise Terraform
`terraform init`

View Terraform Plan
`terraform plan`

Deploy Terraform Resources
`terraform apply` - at end of the generated plan enter yes.

Wait for a short duration whilst the servers configure appropriately.

To view the content on hosted on the webserver use the public ip of the proxy instance in the browser. This is output from running the terraform commands. Allow the duration of time for the servers to self configure. Please enjoy the webcontent.

## Notes
The placeholder values that can be replaces are within the terraform.tfvars file and have comments accordingly.

The webserver dashboard takes a while to populate with data so allow 5 - 10 minutes for this.

To ensure the proxy is still accessible by ssh, given it is proxying port 22 to the webserver, I have configured it to listen on port 23456 for ssh, it can therefore be accessed via `ssh -i ~/.ssh/<appropriate-private-key> ec2-user@<proxy-server-public-ip> -p23456`

As the webserver instance is to be made private this would normally mean creating a NAT Gateway and providing the webserver with access via an appropriate routing table. Due to the steep costs associated with a NAT Gateway I have not done that for this demonstration.
Instead the webserver is open to the internet on start up to allow for packages to be installed. After this the webserver has sufficient permissions to remove it's own security group rules which made it public - rendering it private.
Normally two subnets would be generated, 1 public and 1 private, and the instances placed appropriately. However, due to the issue mentioned above regarding the NAT Gateway this was again avoided and they both share the same public subnet to make use of the internet gateway on start up.

In an actual scenario I would not use these methods but due to the constraint of staying within the AWS free tier for the purposes of this demo these are the steps I have implemented. 
I hope my knowledge of proper process and ability to adapt and overcome this unique situation shows my comprehension on this topic and I'd be happy to discuss this.

## Pipeline
I have included a directory for the stretch goal 2 which is named "pipeline".
This directory is configured as I would for a gitlab ci-cd pipeline utilising gitlab runners. I have taken this path as it is the one I am currently using most often on my clients work.
The structure is simple with a gitlab-ci.yml file which states all stages and jobs of the ci-cd pipeline. It includes the files sourced from the sub directories which are specific to the jobs.
This file is partially psuedo-code and solely for example purposes due to the nature of not knowing Phrasee's systems. I am happy to talk through this also.
