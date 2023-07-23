resource "aws_security_group" "proxy_server_sg" {
    name_prefix = "proxy_server-sg-"

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
    ingress {
        from_port = 23456
        to_port = 23456
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "proxy_server_instance" {
    ami           = var.ami_id  # Uses basic AWS Linux AMI but can be replaced based on Region - changes to distro will need reflecting in the instance_user_data accordingly
    instance_type = var.instance_type
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.proxy_server_sg.id]
    subnet_id = var.subnet_id


    user_data = <<-EOT
                #!/bin/bash
                logdir=/var/log
                logfile=$logdir/user_data.log
                exec >> $logfile 2>&1
                yum update -y
                yum install -y nginx
                systemctl start nginx
                yum install -y nginx-mod-stream
                sed -i 's/#Port 22/Port 23456/' /etc/ssh/sshd_config
                sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
                systemctl restart sshd
                cat > /etc/nginx/nginx.conf << EOCF
                load_module /usr/lib64/nginx/modules/ngx_stream_module.so;
                worker_processes auto;

                events {
                    worker_connections 1024;
                }

                http {
                    # ... Other http settings ...

                    server {
                        listen 80;

                        # Forward HTTP requests to the target instance
                        location / {
                            proxy_pass http://${aws_instance.webserver_instance.private_ip};
                            # Add any additional proxy settings as needed
                        }
                    }
                }
                stream {
                    upstream web1-ssh {
                        server ${aws_instance.webserver_instance.private_ip}:22;
                    }

                    server {
                        listen 22;
                        proxy_pass web1-ssh;
                    }
                }
                EOCF
                systemctl restart nginx
                EOT

    tags = {
    Name = "phrasee-proxy-server"
    }
    depends_on = [ aws_instance.webserver_instance ]
}

output "proxy_ip" {
    value = aws_instance.proxy_server_instance.public_ip
}