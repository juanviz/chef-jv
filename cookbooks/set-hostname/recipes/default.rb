# Cookbook set-hostname => adds hostname to localhosts line in /etc/hosts 
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#
###############################################################

##
# Performs the following operations: 
# Delete existing lines (the ones that starts with 127.0.0.1 => the ones that corresponds with localhost)
# Add to /etc/hosts the following line
# 127.0.0.1   localhost localhost.localdomain #{node hostname}
# hostname is retrieved from chef (via attribute :hostname). 
#
# for cases when etc/hosts has a size 0 (the default ones, as the only line it has the file is removed), add and empty file to the end of the file
# If file doesn't has one line at least, sed will fails
##

Chef::Log.info "sed '1 127.0.0.1   localhost localhost.localdomain #{node[:hostname]}' /etc/hosts"
bash "" do
	user "root"
	cwd "/tmp"
	code <<-EOH
	sed -i '/^127.0.0.1/d' /etc/hosts
	# If /etc/hosts file is size = 0 then add an empty line to avoid sed error 
	if [[ $(stat -c%s /etc/hosts) -eq 0 ]];then echo "" >> /etc/hosts;fi

	sed -i '1 i 127.0.0.1   localhost localhost.localdomain #{node[:hostname]}' /etc/hosts
	EOH
end

