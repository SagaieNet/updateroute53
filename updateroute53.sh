#!/bin/bash
###############################################################################################
### Script per actualitzar els registres dns de les ip's dinamiques d'instancies Amazon AWS ###
###############################################################################################

export EC2_HOME=/root/.ec2
export EC2_URL="https://ec2.eu-west-1.amazonaws.com"
export PATH=$PATH:$EC2_HOME/bin:~/bin/
export EC2_PRIVATE_KEY=`ls $EC2_HOME/certs/pk-*.pem`
export EC2_CERT=`ls $EC2_HOME/certs/cert-*.pem`
export JAVA_HOME=/usr/



ec2-describe-tags --filter key=Route53Name | awk '{print $3 " " $5}' | uniq > /tmp/ec2-describe-tags.name
ec2-describe-tags --filter key=Route53Zone | awk '{print $3 " " $5}' | uniq > /tmp/ec2-describe-tags.zone
ec2-describe-tags --filter key=Route53Cname | awk '{print $3 " " $5}' | uniq > /tmp/ec2-describe-tags.cname
ec2-describe-instances | grep ^INSTANCE | grep -v stopped | awk '{print $2 " " $14}' > /tmp/ec2-describe-instances.miki
cat /tmp/ec2-describe-tags.name | while read i name
do
zone=`cat /tmp/ec2-describe-tags.zone | grep $i |awk '{print $2}' | uniq`
ip=`cat /tmp/ec2-describe-instances.miki | grep $i | awk '{print $2}'`
cname=`cat /tmp/ec2-describe-tags.cname | grep $i | awk '{print $2}'`
exists=`/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 -l $zone. | awk '{print $1}' | uniq | grep -x $name.$zone.`

#cnameexists=`/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 -l $zone. | awk '{print $1}' | uniq | grep -x $name.$zone.`

if [ -n "$exists" ]
then

	if [ -n "$name" ]
	then
		echo "Updating $name.$zone with ip $ip"
		/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 --zone $zone. -g --name $name.$zone. --type A --ttl 60 --values $ip --no-wait
	fi

else

	if [ -n "$name" ]
	then
		echo "Creating $name.$zone with ip $ip"
		/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 --zone $zone. -c --name $name.$zone. --type A --ttl 60 --values $ip --no-wait
	fi

fi

for j in `echo $cname | sed 's/,/\n/g'`
do
	cnameexists=`/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 -l $zone. | awk '{print $1}' | uniq | grep -x $j.$zone.`
	if [ -n "$cnameexists" ]
	then
		echo "Updating CNAME $j.$zone"
		/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 --zone $zone. -g --name $j.$zone. --type CNAME --ttl 60 --values $name.$zone --no-wait
	else
		echo "Creating CNAME $j.$zone"
		/var/lib/gems/1.8/gems/route53-0.2.1/bin/route53 --zone $zone. -c --name $j.$zone. --type CNAME --ttl 60 --values $name.$zone --no-wait
	fi
done

done
