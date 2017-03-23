#!/usr/bin/env bash

cp galaxy_service.sh /etc/init.d/galaxy
for runlevel in 2 3 5 ; do
	ln -s ../init.d/galaxy /etc/rc${runlevel}.d/S99galaxy
done
