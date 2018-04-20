export TOOLS=all
export ENABLE_GUI=false
export ENABLE_AZERTY=false
DEV_TOOLS=$(PWD)/w4m-config/tool_list_LCMS_dev.yaml
PROD_TOOLS=$(PWD)/w4m-config/tool_list_LCMS.yaml
export TOOL_LIST=

all: dev

notools: TOOLS=
notools: build

dev: VERSION=dev
dev: build

prod: VERSION=prod
prod: build

guidev: ENABLE_GUI=true
guidev: dev

guiprod: ENABLE_GUI=true
guiprod: prod

guidevaz: ENABLE_AZERTY=true
guidevaz: guidev

guiprodaz: ENABLE_AZERTY=true
guiprodaz: guiprod

build:
	vagrant up

update:
	vagrant box update

clean:
	vagrant halt
	vagrant destroy -f

.PHONY: all clean build dev prod guidev guiprod devaz prodaz guidevaz guiprodaz notools
