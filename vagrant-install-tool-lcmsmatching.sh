#!/usr/bin/env bash

branch=$1
tools_dir=galaxy/tools

if [[ -d $tools_dir ]] ; then

	old_dir=$(pwd)

	cd $tools_dir
	git clone -b $branch https://github.com/workflow4metabolomics/lcmsmatching
	cd $old_dir

	# Set tool in tool config file
	tool_conf=galaxy/config/tool_conf.xml
	tool_xml=lcmsmatching/lcmsmatching.xml
	tool_conf_old=$tool_conf.old
	cp $tool_conf $tool_conf_old
	xmlstarlet ed --subnode "/toolbox/section[@id='LCMS-annotation']" --type elem -n tool $tool_conf_old | xmlstarlet ed --insert "/toolbox/section[@id='LCMS-annotation']/tool[not(@file)]" --type attr -n file -v $tool_xml >$tool_conf
fi
