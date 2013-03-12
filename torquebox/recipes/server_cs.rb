include_recipe 'java'
#include_recipe 'runit'
include_recipe 'silverware'

version = node[:torquebox][:version]
prefix = "/opt/torquebox/torquebox-#{version}"
current = node[:torquebox][:torquebox_dir]
clustered = node[:torquebox][:clustered]

ENV['TORQUEBOX_HOME'] = current
ENV['JBOSS_HOME'] = "#{current}/jboss"
ENV['JRUBY_HOME'] = "#{current}/jruby"
ENV['PATH'] = "#{ENV['PATH']}:#{ENV['JRUBY_HOME']}/bin:#{ENV['JBOSS_HOME']}/bin"

#package "unzip"
#package "upstart"

user "torquebox" do
  comment "torquebox"
  home "/home/torquebox"
  supports :manage_home => true
end

install_from_release('torquebox') do
  release_url   node[:torquebox][:url]
  home_dir      prefix
  action        [:install, :install_binaries]
  version       version
  checksum      node[:torquebox][:checksum]
  not_if{ File.exists?(prefix) }
end

template "/etc/profile.d/torquebox.sh" do
  mode "755"
  source "torquebox.erb"
end

link current do
  to prefix
end

# # Allow bind_ip entries like ["cloud", "local_ipv4"]
# if node[:torquebox][:bind_ip].is_a?(Array)
#   node.set[:torquebox][:bind_ip_resolved] = node[:torquebox][:bind_ip].inject(node) do |hash, key|
#     hash[key]
#   end
# else
#   node.set[:torquebox][:bind_ip_resolved] = node[:torquebox][:bind_ip]
# end

# if clustered
#   node.set[:torquebox][:peers] = discover_all(:torquebox, :server).map(&:private_ip)
#   node.set[:torquebox][:peers].delete(node[:private_ip])
#   node.set[:torquebox][:mod_cluster_proxies] = discover_all(:mod_cluster, :server).map(&:private_ip)
#   node.set[:torquebox][:server_config] = "standalone-ha.xml"
# end

# template "#{current}/jboss/standalone/configuration/standalone-ha.xml" do #
#   variables({ :options => node[:torquebox] })
#   source node[:torquebox][:ha_server_config_template]
#   owner "torquebox"
#   group "torquebox"
#   mode "0644"
# end

execute "chown torquebox" do
  command "chown -R torquebox:torquebox /usr/local/share/torquebox-#{version}"
  command "chown -R torquebox:torquebox /opt/torquebox"
end

directory node[:torquebox][:log_dir] do
  owner "torquebox"
  group "torquebox"
  mode "0755"
  action :create
end

# runit_service "torquebox" do
#   options   node[:torquebox]
#   run_state node[:torquebox][:run_state]
# end

directory "/etc/jboss-as" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

template "/etc/jboss-as/jboss-as.conf" do
  # variables({ :options => node[:torquebox] })
  source "jboss-as-conf.erb"
  owner "torquebox"
  group "torquebox"
  mode "0644"
end

execute "adding jboss-as file to init.d" do
  command "cp /opt/torquebox/current/jboss/bin/init.d/jboss-as-standalone.sh /etc/init.d/jboss-as-standalone"
end

execute "chkconfig the jboss stuff" do
  command "chkconfig --add jboss-as-standalone"
  command "chkconfig jboss-as-standalone on"
end

execute "set network limits" do
  command "echo 'net.core.wmem_max=640000' >> /etc/sysctl.conf"
  command "echo 'net.core.rmem_max=31457280' >> /etc/sysctl.conf"
  command "sysctl -p"
end

announce(:torquebox, :server)

# otherwise bundler won't work in jruby
gem_package 'jruby-openssl' do
  gem_binary "#{current}/jruby/bin/jgem"
end

#allows use of 'torquebox' command through sudo
cookbook_file "/etc/sudoers.d/torquebox" do
  source 'sudoers'
  owner 'root'
  group 'root'
  mode '0440'
end
