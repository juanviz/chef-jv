#
# Cookbook mongodb => adds mongodb configs servers ips to /etc/hosts 
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
###############################################################


# iterate over the has (config-node-etc-hosts)
# for each of them 
# 1.Search all nodes with role #{key}
# mount host line by <ip hostname #{valuehash} i> 
# i is reseted in every iteration of the hash to #{initial}


initial = 1

host_lines = ["# CHEF-Mongodb::host_mongoconfig (dynamically generated by chef, do not delete the comments from this line to the end line)"]

node["mongodb"]["config-node-prefix"].each do |k,v|
	search_term = k.dup
	prefix = v.dup
	i = initial
	nodes = search(:node,"#{search_term} AND chef_environment:#{node.chef_environment}")
	nodes.sort! { |a,b| a.name <=> b.name }
	nodes.each do |item|
		ip = item['ipaddress']
		hostname = item['hostname']       
		host_lines.push("#{ip}   #{hostname}  #{item.name}" )
		i = i+1
	end
end
host_lines.push("# END CHEF")


# Using sed, remove possible previous config added by this recipe, so that we always have the most fresh config
bash "Remove old /etc/hosts config" do
	user "root"
	cwd "/tmp"
	code <<-EOH
	sed -i '/^\s*# CHEF-Mongodb::host_mongoconfig/,/# END CHEF\s*$/ d' /etc/hosts
	EOH
end


# Add new config
host_lines.each do |line|
	 Chef::Log.info "Line etc-host: #{line}"
	bash "add to etc-hosts mongoconfig" do
		user "root"
		cwd "/tmp"
		code <<-EOH
		echo "#{line}" >> /etc/hosts
		EOH
	end
end
