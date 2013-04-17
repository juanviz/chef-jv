#
# Cookbook Recipe to create a new EBS volume
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#

include_recipe "aws"
aws = data_bag_item("aws", "main")

user = node['mongodb']['user']
group = node['mongodb']['group']
fspt = node['mongodb']['fs']['path'] #filesystem path for ebs

directory "#{fspt}" do
  owner		"#{user}"
  group		"#{group}"
  mode		"0755"
  recursive true
  action	:create
end

aws_ebs_raid "create_mongo_dir" do
    mount_point fspt
    disk_count node["mongodb"]["raid"]["diskcount"]
    disk_size node["mongodb"]["raid"]["disksize"]
    action [:auto_attach]
end

bash "set permissions over mount point" do
	user "root"
	cwd "/tmp"
	code <<-EOH
		chown -R #{user}:#{group} #{fspt}
	EOH
end



