#!/bin/bash
ecs_cluster_name='Your ECS Cluster name'

echo ECS_CLUSTER=$ecs_cluster_name >> /etc/ecs/ecs.config
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config

# Change docker file (/etc/sysconfig/docker)
#OPTIONS="--default-ulimit nofile=1024:4096"
#OPTIONS="-D --default-ulimit nofile=1024:4096"
sed -i 's/OPTIONS="--default-ulimit nofile=1024:4096"/OPTIONS="-D --default-ulimit nofile=1024:4096"/g' /etc/sysconfig/docker

# Restart docker engine and start ecs agent container
sudo service docker restart
sudo start ecs

# ECS log collector download
curl -O https://raw.githubusercontent.com/awslabs/ecs-logs-collector/master/ecs-logs-collector.sh
mv ecs-logs-collector.sh /home/ec2-user/

# Check ECS agent script
echo "#!/bin/bash
TM=\$(date +%F_%T)
instance_id=\$(curl http://169.254.169.254/latest/meta-data/instance-id)
ecs_agent=\$(docker ps | grep \"/agent\" | wc -l)

if [ \$ecs_agent -eq 0 ]then
  bash /home/ec2-user/ecs-logs-collector.sh
  mv /home/ec2-user/collect /home/ec2-user/\$TM-collect
  mv /home/ec2-user/collect-\$instance_id.tgz /home/ec2-user/\$TM-collect-\$instance_id.tgz
  sudo start ecs
fi
" > /home/ec2-user/ecs-logs-collector-auto.sh

# Add crontab(excute for 1 min)
echo "* * * * * bash /home/ec2-user/ecs-logs-collector-auto.sh" >> /var/spool/cron/root

