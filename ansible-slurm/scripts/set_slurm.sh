#!/usr/bin/env bash
# FlowerK

controller_jobs() {
	# File Auth
	mkdir /var/spool/slurm
	mkdir /var/spool/slurmctld
	mkdir /var/log/slurm
	chown slurm: /var/spool/slurm/
	chown slurm: /var/spool/slurmctld/
	chmod 755 /var/spool/slurm/
	touch /var/log/slurmctld.log
	chown slurm: /var/log/slurmctld.log
	touch /var/log/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log
	chown slurm: /var/log/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log

	# Firewall
	firewall-cmd --permanent --zone=public --add-port=6817/udp
	firewall-cmd --permanent --zone=public --add-port=6817/tcp
	firewall-cmd --permanent --zone=public --add-port=6818/udp
	firewall-cmd --permanent --zone=public --add-port=6818/tcp
	firewall-cmd --permanent --zone=public --add-port=6819/udp
	firewall-cmd --permanent --zone=public --add-port=6819/tcp
	firewall-cmd --reload

	# NTP
	yum install ntp -y
	chkconfig ntpd on
	ntpdate pool.ntp.org
	systemctl start ntpd

	# MariaDB
	cp /etc/slurm/slurmdbd.conf.example /etc/slurm/slurmdbd.conf
	chown slurm: /etc/slurm/slurmdbd.conf
	chmod 600 /etc/slurm/slurmdbd.conf
	touch /var/log/slurmdbd.log
	chown slurm: /var/log/slurmdbd.log

	# Service
	systemctl stop slurmctld
	systemctl start slurmctld
	systemctl start slurmctld.service
}

compute_jobs() {
	# File Auth
	mkdir /var/spool/slurm
	mkdir /var/log/slurm
	chown slurm: /var/spool/slurm
	chmod 755 /var/spool/slurm
	touch /var/log/slurm/slurmd.log
	chown slurm: /var/log/slurm/slurmd.log

	# Firewall
	systemctl stop firewalld
	systemctl disable firewalld

	# NTP
	yum install ntp -y
	chkconfig ntpd on
	ntpdate pool.ntp.org
	systemctl start ntpd

	# Service
	systemctl start slurmd.service
}

if [ -n $1 ]; then
	TEST=$1
	SLURM_TYPE=`echo ${TEST} | tr '[A-Z]' '[a-z]'`
	if [ $SLURM_TYPE eq "controller" ]; then
		controller_jobs
	else
		compute_jobs
	fi
else
	exit 128
fi

