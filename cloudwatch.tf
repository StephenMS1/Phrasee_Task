resource "aws_cloudwatch_dashboard" "webserver-dashboard" {
    dashboard_name = "webserver-dashboard"
    dashboard_body = <<EOF
    {
        "widgets": [
            {
                "type":"metric",
                "x":0,
                "y":0,
                "width":12,
                "height":6,
                "properties":{
                    "metrics":[
                        [
                            "AWS/EC2",
                            "CPUUtilization",
                            "InstanceId",
                            "${aws_instance.webserver_instance.id}"
                        ]
                    ],
                    "period":10,
                    "stat":"Average",
                    "region":"${var.region}",
                    "title":"Webserver CPU Utilisation",
                    "liveData": true,
                    "legend": {
                        "position": "right"
                    }
                }
            },
            {   
                "type":"metric",
                "x":0,
                "y":0,
                "width":12,
                "height":6,
                "properties":{
                    "metrics": [
                        [ 
                            "AWS/Logs",
                            "IncomingLogEvents",
                            "LogGroupName",
                            "nginx",
                            { "yAxis": "left" }
                            ]
                    ],
                    "view": "timeSeries",
                    "stacked": false,
                    "region": "${var.region}",
                    "title":"NGINX Incoming Log Events",
                    "stat": "Maximum",
                    "period": 120,
                    "liveData": true
                }
            }
        ]
    }
    EOF 
    depends_on = [ aws_instance.webserver_instance ]
}