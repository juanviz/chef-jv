#include_recipe "mysql::server"
#include_recipe "database::mysql"
app_name = 'wiki_app'
app_secrets = Chef::EncryptedDataBagItem.load("secrets", app_name) 

# Get mysql root password
mysql_secrets = Chef::EncryptedDataBagItem.load("secrets", "mysql")
mysql_root_pass = mysql_secrets[node.chef_environment]['root'] 

mysql_connection_info = {
  :host => "localhost",
  :username => "root",
  :password => mysql_secrets[node.chef_environment]['root']
}

# Create application database
ruby_block "create_#{app_name}_db" do
  block do
    %x[mysql -uroot -p#{mysql_root_pass} -e "CREATE DATABASE #{node[app_name]['db_name']};"]
  end 
  not_if "mysql -uroot -p#{mysql_root_pass} -e \"SHOW DATABASES LIKE '#{node[app_name]['db_name']}'\" | grep #{node[app_name]['db_name']}";
  action :create
end

# Get a list of web servers
webservers = node['roles'].include?('webserver') ? [{'ipaddress' => 'localhost'}] : search(:node, "role:webserver AND chef_environment:#{node.chef_environment}")

# Grant mysql privileges for each web server 
webservers.each do |webserver|
  ip = webserver['ec2']['hostname']
  ruby_block "add_#{ip}_#{app_name}_permissions" do
    block do
      %x[mysql -u root -p#{mysql_root_pass} -e "GRANT SELECT,INSERT,UPDATE,DELETE \
        ON #{node[app_name]['db_name']}.* TO '#{node[app_name]['db_user']}'@'#{ip}' IDENTIFIED BY '#{app_secrets[node.chef_environment]['db_pass']}';"]
    end
    not_if "mysql -u root -p#{mysql_root_pass} -e \"SELECT user, host FROM mysql.user\" | \
      grep #{node[app_name]['db_user']} | grep #{ip}"
    action :create
  end
#mysql_database "#{node[app_name]['db_name']}" do
#  connection mysql_connection_info
#  sql "source /var/www/current/wikijv.sql;"
#end
# Filling application database
#ruby_block "import_#{app_name}_db" do
#  block do
#    %x[mysql -uroot -p#{mysql_root_pass} -D {node[app_name]['db_name']} < {node[app_name]['seed_file']} ;"]
#  end
#  not_if "mysql -uroot -p#{mysql_root_pass} -D {node[app_name]['db_name']} -e \"SHOW TABLES'\" | grep archive";
#  action :create
#end

end
ruby_block "import_#{app_name}_db" do
  block do
    %x[mysql -uroot -p#{mysql_root_pass} -D {node[app_name]['db_name']} < {node[app_name]['seed_file']} ;"]
  end
  not_if "mysql -uroot -p#{mysql_root_pass} -D {node[app_name]['db_name']} -e \"SHOW TABLES'\" | grep archive";
  action :create
end
