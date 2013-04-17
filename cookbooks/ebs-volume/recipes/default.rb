#
# Cookbook Recipe to create a new EBS volume
# Recipe:: default
#
#

include_recipe "aws"

aws = data_bag_item("aws", "main")
users_bag = data_bag_item('users', 'apps_users')
user = users_bag[node.chef_environment]["user"]
group = users_bag[node.chef_environment]["group"]
fspt = node['ebs-volume']['path'] #filesystem path for ebs
ebs_disk_count = node['ebs-volume']["raid"]["diskcount"]
ebs_disk_size = node['ebs-volume']["raid"]["disksize"]

aws_ebs_raid "create_ebs_dir" do
    mount_point fspt
    disk_count node['ebs-volume']["raid"]["diskcount"]
    disk_size node['ebs-volume']["raid"]["disksize"]
    action [:auto_attach]
end

script "set-ebs-permissions" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "/tmp"
  code <<-EOH
    chown -R #{user}:#{group} #{fspt}
  EOH
end