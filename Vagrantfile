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

def message(msg:, config: nil, provision: false)

  # Print now
  if provision
    puts "[PROVISIONING] #{msg}"
  else
    puts "[INFO] #{msg}"
  end

  # Print when provisioning
  if provision and not config.nil?
    config.vm.provision "shell", privileged: false, inline: "echo \"---------------- W4M VM ---------------- #{msg}\""
  end
end

# Load tools list {{{1
################################################################

def load_tools_list()
  
  tools_list_file = "w4m-config/tool_list.yaml"
  message(msg: "LOAD tools list #{tools_list_file}")
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
      message(msg:"Loading information for tool #{name}.")
      tools.push(name)
    else
      message(msg:"CAUTION no GitHub repository for tool #{name}. This tool is impossible to install.")
    end
  end
  
  return tools
end

# Set keyboard layout {{{1
################################################################

def set_keyboard_layout(config)
  
  restart_required = false
  
  keyboard = "qwerty"
  if ! ENV['W4MVM_KEYBOARD'].nil? and ! ENV['W4MVM_KEYBOARD'].empty?
    keyboard = ENV['W4MVM_KEYBOARD']
  end
  message(config: config, msg: "Setting keyboard as #{keyboard}.", provision: true)
  if keyboard != 'qwerty'
    config.vm.provision :shell, privileged: true, inline: "sed -i -e 's/^exit 0/loadkeys fr ; &/' /etc/rc.local"
    restart_required = true
  end
  
  return restart_required
end

# Install Galaxy {{{1
################################################################

def install_galaxy(config)
  
  message(config: config, msg: "Installing Galaxy.", provision: true)
  
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
end

# Install Galaxy tools {{{1
################################################################

def install_galaxy_tools(config)
  if ENV['W4MVM_TOOLS'].nil?
    message(config: config, msg: "NO TOOLS INSTALLATION", provision: true)
  else
    
    # Install requirements
    message(config: config, msg: "INSTALL xmlstarlet", provision: true)
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
      message(config: config, msg: "INSTALLATION OF ALL TOOLS", provision: true)
      tools = get_tool_names(tools_list)
    else
      tools = ENV['W4MVM_TOOLS']
      message(config: config, msg: "INSTALLATION OF TOOLS #{tools}", provision: true)
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
        message(config: config, msg: "Install version #{version} of tool #{name}.", provision: true)
        
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
        
        # Enable HTML output rendering
        if tool.key?('html_output') and tool['html_output']
          message(config: config, msg: "Allow rendering of HTML for tool #{name}.", provision: true)
          config.vm.provision "shell", privileged: false, inline: "echo #{name} >> galaxy/config/sanitize_whitelist.txt"
        end
      end
    end
  end
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
    message(config: config, msg: "SETTING VM NAME AS \"#{vm_name}\"", provision: true)
    config.vm.define vm_name
    config.vm.provider :virtualbox do |vb|
      vb.name = vm_name
    end
  end

  # Network
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  # Set virtual memory
  message(config: config, msg: envvar_enabled('W4MVM_SHOW') ? 'SHOW VIRTUAL MACHINE' : 'HIDE VIRTUAL MACHINE', provision: true)
  config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.gui = envvar_enabled('W4MVM_SHOW')
  end
 
  # Set keyboard layout
  restart_required = set_keyboard_layout(config)
 
  # Install Galaxy
  install_galaxy(config)

  # Install Galaxy tools
  install_galaxy_tools(config)

  # Finalize
  if restart_required
    # Restart machine
    config.vm.provision :shell, privileged: true, inline:"shutdown -r now"
  else
    # Start galaxy in daemon mode
    message(config: config, msg: "START GALAXY IN DAEMON MODE", provision: true)
    config.vm.provision :shell, privileged: true, inline:"service galaxy start"
  end

end
