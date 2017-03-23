export TOOLS=all
export BRANCH=develop

all: dev

notools: TOOLS=
notools: build

dev: BRANCH=develop
dev: build

prod: BRANCH=master
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

update:
	vagrant box update

clean:
	vagrant halt
	vagrant destroy -f

.PHONY: all clean build dev prod guidev guiprod devaz prodaz guidevaz guiprodaz notools
