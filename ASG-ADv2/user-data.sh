#!/bin/bash
yum update -y
# Install web service
yum install -y httpd
service httpd start
chkconfig httpd on
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
# Install NGINX
yum install -y nginx
systemctl enable nginx
systemctl start nginx
# Create script to copy files from S3
touch /tmp/startup.sh
echo "#!/bin/bash" >> /home/ec2-user/startup.sh
echo "echo 'Copy files from S3...'" >> /home/ec2-user/startup.sh
echo "aws s3 cp s3://s3-demo-asg-counter-app-repo-01/ /var/www/html/ --recursive" >> /home/ec2-user/startup.sh
chmod +x /tmp/startup.sh
# Update script in Cronjob to run at startup
touch /tmp/dump
echo "@reboot bash /home/ec2-user/startup.sh" >> /tmp/dump
crontab /tmp/dump
# service crond reload




