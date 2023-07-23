resource "aws_security_group" "webserver_sg" {
    name_prefix = "webserver-sg-"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.proxy_server_sg.id]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.proxy_server_sg.id]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        security_groups = [aws_security_group.proxy_server_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "webserver_instance" {
    ami           = var.ami_id  
    instance_type = var.instance_type
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.webserver_sg.id]
    iam_instance_profile = aws_iam_instance_profile.webserver_instance_profile.name
    subnet_id = var.subnet_id


    user_data = <<-EOT
                #!/bin/bash
                logdir=/var/log
                logfile=$logdir/user_data.log
                exec >> $logfile 2>&1
                yum update -y
                yum install -y docker
                yum install -y pip
                pip3 install boto3
                mkdir -p /usr/share/nginx/html/
                mkdir -p /var/log/nginx/
                cat > /usr/local/bin/copy_s3_file.py << EOPF
                import boto3

                s3_client = boto3.client('s3', region_name='${var.region}')
                s3_client.download_file('phrasee-task-bucket', 'index.html', '/usr/share/nginx/html/index.html')
                s3_client.download_file('phrasee-task-bucket', 'javascript.js', '/usr/share/nginx/html/javascript.js')
                s3_client.download_file('phrasee-task-bucket', 'styles.css', '/usr/share/nginx/html/styles.css')
                EOPF
                chmod +x /usr/local/bin/copy_s3_file.py
                python3 /usr/local/bin/copy_s3_file.py
                service docker start
                docker run -d -p 80:80 --name phrasee_container --mount type=bind,source=/usr/share/nginx/html/,target=/usr/share/nginx/html/ --mount type=bind,source=/var/log/nginx/,target=/var/log/nginx/ nginx
                docker exec phrasee_container sed -i 's/\$status \$body_bytes_sent "\$http_referer" /\$status \$body_bytes_sent \$upstream_response_time "\$http_referer" /' /etc/nginx/nginx.conf
                yum install -y amazon-cloudwatch-agent
                cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << EOCF
                {
                    "agent": {
                        "run_as_user": "root"
                    },
                    "logs": {
                        "logs_collected": {
                            "files": {
                                "collect_list": [
                                    {
                                        "file_path": "/var/log/nginx/access*",
                                        "log_group_name": "nginx",
                                        "log_stream_name": "{instance_id}",
                                        "retention_in_days": 7
                                    }
                                ]
                            }
                        }
                    }
                }
                EOCF
                sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
                aws ec2 revoke-security-group-ingress --group-id ${aws_security_group.webserver_sg.id} --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges="[{CidrIp=0.0.0.0/0}]"
                aws ec2 revoke-security-group-ingress --group-id ${aws_security_group.webserver_sg.id} --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=0.0.0.0/0}]"
                EOT

    tags = {
    Name = "phrasee-webserver"
    }
}

resource "aws_iam_policy" "s3_access_policy" {
    name        = "S3AccessAndCloudWatchLogsPolicy"
    description = "Custom policy to access the html content in S3 bucket"

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Effect    = "Allow"
        Action    = [
            "s3:GetObject",
            "s3:ListBucket"
        ]
        Resource  = ["arn:aws:s3:::${aws_s3_bucket.testing_bucket.bucket}/*"]
        },
        {
        Effect    = "Allow",
        Action    = [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
        ],
        Resource  = "*"
        },
        {
        Effect    = "Allow",
        Action    = [
                "ssm:GetParameter"
        ],
        Resource  = "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        },
        {
        Effect    = "Allow",
        Action    = [
                "ec2:AuthorizeSecurityGroupIngress", 
                "ec2:RevokeSecurityGroupIngress", 
                "ec2:AuthorizeSecurityGroupEgress", 
                "ec2:RevokeSecurityGroupEgress", 
                "ec2:ModifySecurityGroupRules",
                "ec2:UpdateSecurityGroupRuleDescriptionsIngress", 
                "ec2:UpdateSecurityGroupRuleDescriptionsEgress"
        ],
        Resource  = "*"
        }
    ]
    })
}

resource "aws_iam_role" "webserver_instance_role" {
    name = "webserver_instance_role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        }
    ]
    })
}

resource "aws_iam_role_policy_attachment" "webserver_instance_policy_attachment" {
    policy_arn = aws_iam_policy.s3_access_policy.arn
    role       = aws_iam_role.webserver_instance_role.name
}

resource "aws_iam_instance_profile" "webserver_instance_profile" {
    name = "webserver-instance-profile"
    role = aws_iam_role.webserver_instance_role.name
}