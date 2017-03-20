DEV_TOOLS="tools-playbook-list/tool_list_LCMS_dev.yaml"
PROD_TOOLS="tools-playbook-list/tool_list_LCMS.yaml"

all:

notools: build

dev: TOOL_LIST=$(DEV_TOOLS)
dev: build

prod: TOOL_LIST=$(PROD_TOOLS)
prod: build

guidev: ENABLE_GUI=true
guidev: dev

guiprod: ENABLE_GUI=true
guiprod: prod

devaz: ENABLE_AZERTY=true
devaz: dev

prodaz: ENABLE_AZERTY=true
prodaz: prod

guidevaz: ENABLE_AZERTY=true
guidevaz: guidev

guiprodaz: ENABLE_AZERTY=true
guiprodaz: guiprod

build:
	vagrant up

clean:
	vagrant halt
	vagrant destroy -f

.PHONY: all clean build dev prod guidev guiprod devaz prodaz guidevaz guiprodaz notools
