#
# Cookbook Recipe to create a new EBS volume
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#

include_recipe "aws"
aws = data_bag_item("aws", "main")

user = node['rsyslog']['user']
fspt = node['rsyslog']['logs']['dir']
 #filesystem path for ebs

directory "#{fspt}" do
  owner		"#{user}"
  group		"root"
  mode		"0755"
  recursive true
  action	:create
end

aws_ebs_raid "create_logs_dir" do
    mount_point fspt
    disk_count 2
    disk_size 1
    action [:auto_attach]
end



