subnet_id = "subnet-0501f231c276e947f" #replace with the vpc id you wish to use
instance_type = "t2.micro" #replace if you wish to differently size the instances
key_name = "StephenKeyPair" #replace with an appropriate key pair
ami_id = "ami-020737107b4baaa50" # basic AWS linux ami for the eu-west-2 region - if changing this to a different distro the user-data may not work. If deploying in another region this will need to be changed accordingly
region = "eu-west-2" # this region is linked to the ami, as mentioned above, so please account for this if changing region