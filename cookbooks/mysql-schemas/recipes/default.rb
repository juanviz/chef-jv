#
# Cookbook Name:: mysql-schemas
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)
#

###
#	DB schemas files definition, we get the URL defined in attributes.
###

smp_batch_url = node['smpbatch']['schema']['url']

remote_file "/tmp/smp_batch.sql" do
  source smp_batch_url
  mode "0644"
#  checksum "08da002l" # A SHA256 (or portion thereof) of the file.
end

_schema_url = node['jv']['schema']['url']

remote_file "/tmp/jv_schema.sql" do
  source _schema_url
  mode "0644"
#  checksum "08da002l" # A SHA256 (or portion thereof) of the file.
end


_ss_url = node['jv']['ss']['url']

remote_file "/tmp/lite_sss.sql" do
  source _ss_url
  mode "0644"
#  checksum "08da002l" # A SHA256 (or portion thereof) of the file.
end


###
##   Script to load the schemas for mysql
##	- Creates the databases
##	- Creates the users and give them the required permissions to access. (GIVEN PERMISSION TO ACCESS FROM EVERYWHERE, to be restricted!! )
##	- Imports each schema it its own database
###
script "load_schema" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
 
  mysql -u root -e "CREATE USER 'jv'@'%' IDENTIFIED BY 'jv';"
  mysql -u root -e "create database lite_jv character set utf8;"
  mysql -u root -e "GRANT ALL PRIVILEGES ON lite_jv.* TO 'jv'@'%' IDENTIFIED BY 'jv';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON lite_jv.* TO 'jv'@'localhost' IDENTIFIED BY 'jv';"
  mysql -u root -D lite_jv < /tmp/_schema.sql;

  mysql -u root -e "create database lite_jv_ss character set utf8;"
  mysql -u root -e "GRANT ALL PRIVILEGES ON lite_jv_ss.* TO 'jv'@'%' IDENTIFIED BY 'jv';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON lite_jv_ss.* TO 'jv'@'localhost' IDENTIFIED BY 'jv';"
  mysql -u root -D lite_jv_ss < /tmp/lite__ss.sql;

  mysql -u root -e "CREATE USER 'smpbatch'@'%' IDENTIFIED BY 'smpbatch';"
  mysql -u root -e "create database smp_batch character set utf8;"
  mysql -u root -e "GRANT all privileges on smp_batch.* to smpbatch@'%' IDENTIFIED BY 'smpbatch';"
  mysql -u root -D smp_batch < /tmp/smp_batch.sql;

  mysql -u root -e "flush privileges;"

  EOH
end
