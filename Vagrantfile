# -*- mode: ruby -*-
# vi: ft=ruby sw=0 ts=2 et fdm=marker

require 'yaml'

# Env var enabled {{{1
################################################################

def envvar_enabled(var)
  ! ENV[var].nil? and ['true', 'yes'].include? ENV[var].downcase
end

# Message {{{1
################################################################

def message(msg)
  puts "---------------- W4M VM ---------------- #{msg}"
end


# Provision message {{{1
################################################################

def provision_message(config, msg)
  config.vm.provision "shell", privileged: false, inline: "echo \"---------------- W4M VM ---------------- #{msg}\""
end

# Load tools list {{{1
################################################################

def load_tools_list()
  
  tools_list_file = "w4m-config/tool_list.yaml"
  message("LOAD tools list #{tools_list_file}")
  tools_list = YAML.load_file(tools_list_file)
  
  return tools_list
end

# Get tool names {{{1
################################################################

def get_tool_names(tools_list)
  
  tools = []
  
  # Select all tools
  if not tools_list.key?('tools')
    abort("No tools section inside tools list file.")
  end
  
  tools_list['tools'].each do |tool|
    
    # Check name
    if not tool.key?('name')
      abort("Tool has no name.")
    end
    name = tool['name']
      
    if tool.key?('github')
      message("Selecting tool #{name}.")
      tools.push(name)
    else
      message("CAUTION no GitHub repository for tool #{name}.")
    end
  end
  
  return tools
end

# MAIN {{{1
################################################################

Vagrant.configure(2) do |config|

  restart_required = false
  
  # Box
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "w4m"
  if ! ENV['W4MVM_NAME'].nil?
    vm_name = ENV['W4MVM_NAME']
    provision_message(config, "SETTING VM NAME AS \"#{vm_name}\"")
    config.vm.define vm_name
    config.vm.provider :virtualbox do |vb|
      vb.name = vm_name
    end
  end

  # Network
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  # Set virtual memory
  provision_message(config, envvar_enabled('W4MVM_SHOW') ? 'SHOW VIRTUAL MACHINE' : 'HIDE VIRTUAL MACHINE')
  config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.gui = envvar_enabled('W4MVM_SHOW')
  end
 
  # Set keyboard layout
  keyboard = "qwerty"
  if ! ENV['W4MVM_KEYBOARD'].nil? and ! ENV['W4MVM_KEYBOARD'].empty?
    keyboard = ENV['W4MVM_KEYBOARD']
  end
  provision_message(config, "SETTING KEYBOARD as #{keyboard}")
  if keyboard != 'qwerty'
    config.vm.provision :shell, privileged: true, inline: "sed -i -e 's/^exit 0/loadkeys fr ; &/' /etc/rc.local"
    restart_required = true
  end
 
  # Install Galaxy
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "galaxyserver.yml" 
  end
  config.vm.provision "file", source: "w4m-config/config/tool_conf.xml", destination: "galaxy/config/tool_conf.xml"
  config.vm.provision "file", source: "w4m-config/config/tool_sheds_conf.xml", destination: "galaxy/config/tool_sheds_conf.xml"
  config.vm.provision "file", source: "w4m-config/config/dependency_resolvers_conf.xml", destination: "galaxy/config/dependency_resolvers_conf.xml"
  config.vm.provision "file", source: "w4m-config/static/welcome.html", destination: "galaxy/static/welcome.html"
  config.vm.provision "file", source: "w4m-config/static/W4M", destination: "galaxy/static/W4M"
  config.vm.provision "file", source: "galaxy_service.sh", destination: "galaxy_service.sh"
  for runlevel in [2, 3, 5]
    config.vm.provision :shell, privileged: true, inline: "cp galaxy_service.sh /etc/init.d/galaxy"
    config.vm.provision :shell, privileged: true, inline: "ln -s ../init.d/galaxy /etc/rc#{runlevel}.d/S99galaxy"
  end

  # Install Galaxy tools
  if ENV['W4MVM_TOOLS'].nil?
    provision_message(config, "NO TOOLS INSTALLATION")
  else
    
    # Install requirements
    provision_message(config, "INSTALL xmlstarlet")
    config.vm.provision "shell", privileged: true, inline: "apt-get install -y xmlstarlet"
    
    # Set branch
    if ENV['VERSION'].nil?
      version='dev'
    else
      version=ENV['VERSION']
      if version != 'dev' and version != 'prod'
        abort("Unknown version '#{version}' for tools.")
      end
    end
    
    # Load tools list
    tools_list = load_tools_list()
    
    # Set tools list
    tools = []
    if ENV['W4MVM_TOOLS'] == 'all'
      provision_message(config, "INSTALLATION OF ALL TOOLS")
      tools = get_tool_names(tools_list)
    else
      tools = ENV['W4MVM_TOOLS']
      provision_message(config, "INSTALLATION OF TOOLS #{tools}")
      tools = tools.split(/ */)
      all_tools = get_tool_names(tools_list)
      
      # Check tools
      tools.each do |tool|
        if not all_tools.include?(tool)
          abort("Tool '#{tool}' is unknown.")
        end
      end
    end
    
    # Loop on all tools
    tools_list['tools'].each do |tool|
      name = tool['name']
    
      if tools.include?(name)
        provision_message(config, "INSTALL tool #{name} in #{version} version")
        
        # Clone GitHub repos
        if not tool['github'].key?(version)
          abort("No GitHub branch specified for version #{version} of tool #{name}.")
        end
        branch = tool['github'][version]
        if not tool['github'].key?('repos')
          abort("No GitHub repository specified for tool #{name}.")
        end
        repos = tool['github']['repos']
        config.vm.provision "shell", privileged: false, inline: "git clone -b #{branch} #{repos} galaxy/tools/#{name}"
        
        # Edit tool conf file
        if not tool.key?('xml')
          abort("No XML file name specified for tool #{name}.")
        end
        xml = tool['xml']
        if not tool.key?('tool_panel_section_id')
          abort("No tool panel section ID specified for tool #{name}.")
        end
        section_id = tool['tool_panel_section_id']
        tool_conf = "galaxy/config/tool_conf.xml"
        tool_conf_old = "galaxy/config/tool_conf.xml.old"
        config.vm.provision "shell", privileged: false, inline: "cp #{tool_conf} #{tool_conf_old}"
        config.vm.provision "shell", privileged: false, inline: "xmlstarlet ed --subnode \"/toolbox/section[@id='#{section_id}']\" --type elem -n tool #{tool_conf_old} | xmlstarlet ed --insert \"/toolbox/section[@id='#{section_id}']/tool[not(@file)]\" --type attr -n file -v #{name}/#{xml} >#{tool_conf}"
        #config.vm.provision :shell, privileged: false, path: "vagrant-install-tool-#{name}.sh", args:branch
      end
    end
  end

  # Finalize
  if restart_required
    # Restart machine
    config.vm.provision :shell, privileged: true, inline:"shutdown -r now"
  else
    # Start galaxy in daemon mode
    provision_message(config, "START GALAXY IN DAEMON MODE")
    config.vm.provision :shell, privileged: true, inline:"service galaxy start"
  end

end
