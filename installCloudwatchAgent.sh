#!/bin/bash
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
context="export PROMPT_COMMAND=""'"'RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$]: $(history 1 | sed "s/[ ][0–9]+[ ]//" ) [$RETRN_VAL]"'"'"
echo $context > /etc/bashrc
source /etc/bashrc
echo 'local6.* /var/log/commands.log' > /etc/rsyslog.d/bash.conf
echo '/var/log/commands.log' > /etc/logrotate.d/rsyslog
service rsyslog restart
echo '{
   "metrics":{
      "namespace": "LinuxServer",
      "metrics_collected":{
         "mem":{
            "measurement":[
               "mem_used_percent"
            ],
            "metrics_collection_interval":5
         }
      },
      "append_dimensions":{
         "InstanceId": "${aws:InstanceId}"
      }
   },
   "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            {
                "file_path": "/var/log/commands.log",
                "log_group_name":  "/ec2/bash-history/",
                "log_stream_name": "{instance_id}",
                "timestamp_format": "%d/%b/%Y:%H:%M:%S %z",
                "timezone": "Local"
            }
          ]
        }
      }
    }
} ' >  /opt/aws/amazon-cloudwatch-agent/bin/config.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
systemctl enable amazon-cloudwatch-agent
