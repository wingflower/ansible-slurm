#!/usr/bin/env bash
# FlowerK


if [ -n $1 ]; then
	chown munge: /etc/munge/munge.key
	chmod 400 /etc/munge/munge.key
	chown -R munge: /etc/munge/ /var/log/munge/
	chmod 0700 /etc/munge/ /var/log/munge/
	systemctl enable munge
	systemctl start munge
else
	exit 128
fi

