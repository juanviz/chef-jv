#include_recipe "database::mysql"
include_recipe "s3_file"
app_name = 'wiki_app'
app_secrets = Chef::EncryptedDataBagItem.load("secrets", app_name) 
app_config = node[app_name]
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
  
s3_file app_config['seed_file'] do
    	remote_path app_config['bucket_file']
    	bucket app_config['bucket']
	aws_access_key_id      "AKIAIQSFEY3CKZHHS2AA"
	aws_secret_access_key  "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"
    	owner "ec2-user"
    	group "ec2-user"
    	mode "0644"
    	action :create
    end
ruby_block "import_#{app_name}_db" do
  block do
    %x[mysql -uroot -p#{mysql_root_pass}  #{node[app_name]['db_name']} < /tmp/wikijv.sql;]
  end
  action :create
