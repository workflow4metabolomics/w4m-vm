all:
	./build-vm -d --name w4mdev-qwerty  --wait --halt
	./build-vm -d --name w4mprod-qwerty --wait --halt --prod
	./build-vm -d --name w4mdev-azerty  --wait --halt
	./build-vm -d --name w4mprod-azerty --wait --halt --prod

clean:
	for vm in .vagrant/machines/* ; do W4MVM_NAME=$$(basename $$vm) vagrant destroy -f $$(basename $$vm) ; done

.PHONY: all clean
