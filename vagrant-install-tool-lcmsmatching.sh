#!/usr/bin/env bash

branch=$1
tools_dir=galaxy/tools

if [[ -d $tools_dir ]] ; then

	old_dir=$(pwd)

	cd $tools_dir
	git clone -b $branch https://github.com/workflow4metabolomics/lcmsmatching
	cd $old_dir

	sudo sh -c 'echo "deb http://cran.univ-paris1.fr/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

	# Update and upgrade system
	sudo apt-get update
	sudo apt-get -y upgrade

	# Install tool dependencies
	sudo apt-get -y install r-base libcurl4-openssl-dev libxml2-dev git ant
	sudo R -e "install.packages(c('getopt', 'stringr', 'plyr', 'XML', 'jonslite', 'RUnit'), lib='/usr/lib/R/library', dependencies = TRUE, repos='http://mirrors.ebi.ac.uk/CRAN')"

	# Set tool in tool config file
	tool_conf=galaxy/config/tool_conf.xml
	tool_xml=lcmsmatching/lcmsmatching.xml
	tool_conf_old=$tool_conf.old
	cp $tool_conf $tool_conf_old
	xmlstarlet ed --subnode "/toolbox/section[@id='LCMS-annotation']" --type elem -n tool $tool_conf_old | xmlstarlet ed --insert "/toolbox/section[@id='LCMS-annotation']/tool[not(@file)]" --type attr -n file -v $tool_xml >$tool_conf
fi
