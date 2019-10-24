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

# def message(msg:, config: nil, provision: false)
# 
#   # Print now
#   if provision
#     puts "[PROVISIONING] #{msg}"
#   else
#     puts "[INFO] #{msg}"
#   end
# 
#   # Print when provisioning
#   if provision and not config.nil?
#     config.vm.provision "shell", privileged: false, inline: "echo \"---------------- W4M VM ---------------- #{msg}\""
#   end
# end

# Load tools list {{{1
################################################################

def load_tools_list()
  
  tools_list_file = "w4m-config/tool_list.yaml"
#  message(msg: "LOAD tools list #{tools_list_file}")
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
#      message(msg:"Loading information for tool #{name}.")
      tools.push(name)
    else
#      message(msg:"CAUTION no GitHub repository for tool #{name}. This tool is impossible to install.")
    end
  end
  
  return tools
end


# Install Galaxy tools {{{1
################################################################

def install_galaxy_tools(config, version:'dev')
  if ENV['W4MVM_TOOLS'].nil? or ENV['W4MVM_TOOLS'] == ''
#    message(config: config, msg: "NO TOOLS INSTALLATION", provision: true)
  else
    
    # Install requirements
#    message(config: config, msg: "INSTALL xmlstarlet", provision: true)
    config.vm.provision "shell", privileged: true, inline: "apt-get install -y xmlstarlet"
    
    # Set branch
    if version != 'dev' and version != 'prod'
      abort("Unknown version '#{version}' for tools.")
    end
    
    # Load tools list
    tools_list = load_tools_list()
    
    # Set tools list
    tools = []
    if ENV['W4MVM_TOOLS'] == 'all'
#      message(config: config, msg: "INSTALLATION OF ALL TOOLS", provision: true)
      tools = get_tool_names(tools_list)
    else
      tools = ENV['W4MVM_TOOLS']
#      message(config: config, msg: "INSTALLATION OF TOOLS #{tools}", provision: true)
      tools = tools.split(/ +/)
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
        
        # Clone GitHub repos
        if not tool['github'].key?(version)
          abort("No GitHub branch specified for version #{version} of tool #{name}.")
        end
        branch = tool['github'][version]
        if not tool['github'].key?('repos')
          abort("No GitHub repository specified for tool #{name}.")
        end
        repos = tool['github']['repos']
#        message(config: config, msg: "Install version #{version} (branch/tag #{branch}) of tool #{name}.", provision: true)
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
        
        # Enable HTML output rendering
        if tool.key?('html_output') and tool['html_output']
#          message(config: config, msg: "Allow rendering of HTML for tool #{name}.", provision: true)
          config.vm.provision "shell", privileged: false, inline: "echo #{name} >> galaxy/config/sanitize_whitelist.txt"
        end
      end
    end
  end
end

# Create VM {{{1
################################################################

def create_vm(config:, name:, port:8080, version:'dev')

    config.vm.box = "ubuntu/bionic64"
#    config.vm.box = "generic/ubuntu1804"
#     #    config.vm.box = "archlinux/archlinux"
#     #    config.vm.guest = :alpine # Needed to set hostname. Inside the box generic/alpine38, the guest is set to "alt" (which is wrong).
    config.vm.hostname = "w4m"

    config.vm.provider :virtualbox do |vb|
      vb.name = name
      vb.memory = "2048"
    end
#    config.vm.provision "Package database update.", type: "shell", privileged: true, inline: "apt update"
#    config.vm.provision "Install Python.", type: "shell", privileged: true, inline: "apt install -y python3" # Needed by Ansible
#    config.vm.provision "Install Python.", type: "shell", privileged: true, inline: "apk add python" # Needed by Ansible
#    config.vm.provision "Install Python.", type: "shell", privileged: true, inline: "pacman --noconfirm -S python2" # Needed by Ansible
    config.vm.provision :ansible do |ansible|
      ansible.extra_vars = {
        ansible_python_interpreter: "python3"
      }
      ansible.playbook = "provisioning/playbook.yml"
    end

    # Network
    config.vm.network :forwarded_port, guest: 8080, host: port

    # Install Galaxy tools
    install_galaxy_tools(config, version: version)
end

# MAIN {{{1
################################################################

Vagrant.configure(2) do |config|

#  config.vagrant.plugins = "vagrant-alpine" # For setting hostname on alpine

config.vm.define 'w4mdev-qwerty' do |w4mdev_qwerty|
  create_vm(config: w4mdev_qwerty, name: 'w4mdev-qwerty')
end

config.vm.define 'w4mdev-azerty' do |w4mdev_azerty|
  create_vm(config: w4mdev_azerty, name: 'w4mdev-azerty')
end

config.vm.define 'w4mprod-azerty' do |w4mprod_azerty|
  create_vm(config: w4mprod_azerty, name: 'w4mprod-azerty', version:'prod')
end

config.vm.define 'w4mprod-qwerty' do |w4mprod_qwerty|
  create_vm(config: w4mprod_qwerty, name: 'w4mprod-qwerty', version:'prod')
end
end
