#!/usr/bin/env bash

cp galaxy_service.sh /etc/init.d/galaxy
ln -s ../init.d/galaxy /etc/rc2.d/S99galaxy 
ln -s ../init.d/galaxy /etc/rc3.d/S99galaxy 
ln -s ../init.d/galaxy /etc/rc5.d/S99galaxy 
