default[:torquebox][:version] = "2.3.0"
default[:torquebox][:url] = "http://torquebox.org/release/org/torquebox/torquebox-dist/#{node[:torquebox][:version]}/torquebox-dist-#{node[:torquebox][:version]}-bin.zip"
default[:torquebox][:checksum] = "67434f9dec5c43aa6e3491f31899f00c"
default[:torquebox][:jruby][:opts] = "--1.9"

default[:torquebox][:backstage_gitrepo] = "git://github.com/torquebox/backstage.git"
default[:torquebox][:backstage_home] = "/var/www/backstage"

default[:torquebox][:torquebox_dir] = "/opt/torquebox/current"
default[:torquebox][:log_dir] = "/var/log/torquebox"
default[:torquebox][:bind_ip] = "127.0.0.1"
default[:torquebox][:server_config] = "standalone.xml"
default[:torquebox][:ha_server_config_template] = "standalone-ha.xml.erb"
default[:torquebox][:clustered] = false
# List of peers in this TorqueBox cluster
default[:torquebox][:peers] = []
# List of mod_cluster load balancers for this cluster
default[:torquebox][:mod_cluster_proxies] = []
# Port mod_cluster proxies listen for management messages
default[:torquebox][:mod_cluster_mcpm_port] = 6666

default[:torquebox][:run_state] = :start
