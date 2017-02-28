# -*- mode: ruby -*-
# vi: ft=ruby ts=2 et fdm=marker

# Env var enabled {{{1
################################################################

def envvar_enabled(var)
  ! ENV[var].nil? and ['true', 'yes'].include? ENV[var].downcase
end

# Message {{{1
################################################################

def message(config, msg)
  config.vm.provision "shell", privileged: false, inline: "echo \"---------------- W4M VM ---------------- #{msg}\""
end

# MAIN {{{1
################################################################

Vagrant.configure(2) do |config|

  # Box
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "w4m"

  # Network
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  # Set virtual memory
  message(config, envvar_enabled('ENABLE_GUI') ? 'GUI ENABLED' : 'GUI DISABLED')
  config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.gui = envvar_enabled('ENABLE_GUI')
  end
  
  # Set AZERTY keyboard layout
  if envvar_enabled('ENABLE_AZERTY')
    message(config, 'SETTING AZERTY KEYBOARD')
    config.vm.provision :shell, privileged: true, path: "vagrant-azerty.sh"
  else
    message(config, 'SETTING QWERTY KEYBOARD')
  end
  
  # Create a directory for conda deps closed to / to avoid placehold/placehold ...
  config.vm.provision :shell, privileged: true, path: "vagrant-install-conda.sh"

  # Install Galaxy
  # TODO make a script for starting/stoping Galaxy as a service/daemon. Start automatically at startup of vm.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "galaxyserver.yml" 
#    ansible.sudo = true
  end

  config.vm.provision "file", source: "w4m-config/config/tool_conf.xml", destination: "galaxy/config/tool_conf.xml"
  config.vm.provision "file", source: "w4m-config/config/tool_sheds_conf.xml", destination: "galaxy/config/tool_sheds_conf.xml"
  config.vm.provision "file", source: "w4m-config/config/dependency_resolvers_conf.xml", destination: "galaxy/config/dependency_resolvers_conf.xml"
  config.vm.provision "file", source: "w4m-config/static/welcome.html", destination: "galaxy/static/welcome.html"
  config.vm.provision "file", source: "w4m-config/static/W4M", destination: "galaxy/static/W4M"

  # Start galaxy in daemon mode
  config.vm.provision :shell, privileged: false, path: "vagrant-run-galaxy.sh", args:"start", run: "always"

  # Install Galaxy tools
  if ENV['TOOL_LIST'].nil?
      message(config, "NO TOOLS INSTALLATION")
  else
      message(config, "INSTALLING TOOLS FROM #{ENV['TOOL_LIST']}")
      config.vm.provision :shell, privileged: true, path: "swap_create.sh", args:"4096", run: "always"
      config.vm.provision "ansible" do |ansible|
        ansible.verbose = "v"
        ansible.extra_vars = { 
            "tool_list_file" => ENV['TOOL_LIST'], 
          }
        ansible.playbook = "tools.yml"  
      end
      config.vm.provision :shell, privileged: true, path: "swap_remove.sh", run: "always"
      config.vm.provision :shell, privileged: true, path: "swap_create.sh", args:"1024", run: "always"

      # ReStart galaxy in daemon mode
      # XXX The tools ansible role should restart Galaxy
      config.vm.provision :shell, privileged: false, path: "vagrant-run-galaxy.sh", args:"restart", run: "always"
  end

end
