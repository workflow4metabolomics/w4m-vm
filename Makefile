MACHINES=w4mprod-azerty w4mprod-qwerty w4mdev-azerty w4mdev-qwerty
export W4MVM_TOOLS=all

all: $(MACHINES)

define vagrant_up
$(1):
	vagrant up $$@
endef
$(foreach vm,$(MACHINES),$(eval $(call vagrant_up,$(vm))))

halt:
	$(foreach vm,$(MACHINES),vagrant halt $(vm);)
#	for vm in .vagrant/machines/w4m* ; do vagrant halt $$(basename $$vm) ; done

clean:
	$(foreach vm,$(MACHINES),vagrant destroy -f $(vm);)
#	for vm in .vagrant/machines/w4m* ; do vagrant destroy -f $$(basename $$vm) ; done

.PHONY: all clean
