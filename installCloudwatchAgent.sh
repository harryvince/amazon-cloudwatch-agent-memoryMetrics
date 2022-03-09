#!/bin/bash
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
cat << EOF >  /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
   "metrics":{
      "metrics_collected":{
         "mem":{
            "measurement":[
               "mem_used_percent"
            ],
            "metrics_collection_interval":30
         }
      },
      "append_dimensions":{
         "InstanceId": "${aws:InstanceId}"
      }
   }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
systemctl enable amazon-cloudwatch-agent