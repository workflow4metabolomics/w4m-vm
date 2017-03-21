#!/usr/bin/env bash

branch=$1
tools_dir=galaxy/tools

if [[ -d $tools_dir ]] ; then

	cd $tools_dir
	git clone -b $branch https://github.com/workflow4metabolomics/lcmsmatching

	sudo sh -c 'echo "deb http://cran.univ-paris1.fr/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

	# Update and upgrade system
	sudo apt-get update
	sudo apt-get -y upgrade

	# Install tool dependencies
	sudo apt-get -y install r-base libcurl4-openssl-dev libxml2-dev git ant
	sudo R -e "install.packages(c('getopt', 'stringr', 'plyr', 'XML', 'jonslite', 'RUnit'), lib='/usr/lib/R/library', dependencies = TRUE, repos='http://mirrors.ebi.ac.uk/CRAN')"
fi
