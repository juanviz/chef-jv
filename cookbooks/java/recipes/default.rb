#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)
# Cookbook Name:: java
# Recipe:: default
#

fileserver = data_bag_item('fileserver', 'url')[node.chef_environment]
tarball_url = fileserver + node['java']['jdk-6u13-64']['url']
java_home = node['java']["java_home"]

ruby_block  "set-env-java-home" do
  block do
    ENV["JAVA_HOME"] = java_home
  end
end

file "/etc/profile.d/jdk.sh" do
  content <<-EOS
    export JAVA_HOME=/usr/java/default
    export PATH=/usr/java/default/bin:\$PATH
  EOS
  mode 0755
end

remote_file "/tmp/jdk.rpm" do
  owner "lumata"
  group "lumata"
  source tarball_url
  mode "0755"  
  notifies :run,"bash[purge-java-packages]",:immediately
  notifies :run, "bash[jdk-local-install]",:immediately 
end

# Purge packages (in a bash resource, just for performance issues)
bash "purge-java-packages" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    yum -d0 -e0 -y remove sun-java6-jdk sun-java6-bin sun-java6-jre java-1.6.0-openjdk jdk
    EOH
    action :nothing
end


bash "jdk-local-install" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    yum -y localinstall /tmp/jdk.rpm 
    EOH
    action :nothing
    notifies :run, "script[remove_alternatives and old java]",:immediately
    
end


script "remove_alternatives and old java" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "/tmp"
  code <<-EOH
  update-alternatives --remove java /usr/lib/jvm/java/bin/java
  rm -Rf /usr/lib/jvm/jdk*
  EOH
  action :nothing
end

