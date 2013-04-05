Script to update Amazon Route53 Dns from tags in EC2 machines.

You need https://rubygems.org/gems/route53 installed in your system.

HOW IT WORKS:

- You need to set different tags on your EC2 machines:
	Route53Name: Hostname (example: server1)
	Route53Zone: Route53 hosted domain (example: domain.com)
	Route53Cname: comma separated CNAMEs for the host (example: www,ftp,imap,smtp). Optional.

- Configure the export variables at the beggining of the file:
	EC2_HOME: directory where ec2-tools are installed
	EC2_URL: URL to your EC2 zone


Add the script in cron and run it as many times as you need



Miki Monguilod
