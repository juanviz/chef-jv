
action :register do


	name = new_resource.name
	
	bash "register_service_#{name}" do
	  code <<-EOH
		chkconfig --add #{name}
		chkconfig #{name} on
	  EOH
	end
	
end