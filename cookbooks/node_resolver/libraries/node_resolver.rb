# Provides the following methods to obtain information 
# about endpoints/nodes within the current environment
#
# The following string constanst are used as components indicators

class Chef
	class Recipe
			def endpoints(*components)
		    	result = {}
		    	if components != nil
		    		components.each do |c|
		    			endpoint = get_balanced_endpoint(c)
		    			if(endpoint == nil) # it is not a balanced component 
		    				# get the endpoint of the node (ip:port) using the role to find it
		    				endpoint = get_node_endpoint(c)
		    			end
		    			# add endpoint to result
		    			if(endpoint != nil) 
		    				result[c] = endpoint
		    			end
		    		end
		    	end
		    	return result
		    end
		    # Creates a hash with two keys (uri,port) as a basic representation for an endpoint
		    private
		    def get_endpoint_struct(uri,port)
		    	return {"uri"=>uri,"port"=>port}
		    end
                        
		    # search for roles within current environent
		    private 
		    def search_environment(role)
		    	search_term = "role:#{role} AND chef_environment:#{node.chef_environment}"
		    	Chef::Log.info "Searching nodes using term '#{search_term}'"
		    	search(:node,search_term)
		    end
            
             
		   
		    # Query the node for information about possible balancers for this component. 
		    # If no results are found, it returns nil
		    private
		    def get_balanced_endpoint(component)
		    	if node.has_key? "balancers"
		    		if node["balancers"].has_key? component
		    			return get_endpoint_struct(node["balancers"][component]["name"],
		    				node["balancers"][component]["port"])
		    		end
		    	end
		    	return nil
		    end
		    private 
		    def get_node_endpoint(component)

                if(is_component_static(component))
                    Chef::Log.info "#{component} is static => getting info from databag, search is not used"
                    return get_static_info(component)
                end

		   		# Find role from component
		   	    Chef::Log.info("Component to be used: #{component} and locator is #{locators[component]} ")
		   		nodes = search_environment(locators[component]["role"])		   
				#use only first node (just in case it provides more than one)
				unless locators[component].has_key?"locator"
					return get_endpoint_struct(nodes[0]['ipaddress'],nodes[0][component]['port'])
				else
					ip = nodes[0]['ipaddress']
					port = find_port(nodes[0],locators[component]["locator"].dup)
					return get_endpoint_struct(ip,port)
				end
		    end

		    # Provides and easy way to find recursively into an hash from a list of keys
		    # locator : array of keys, ordered
		    # node : Chef node in which we want to search
		    # REcursive Base: If length of locator is 1, then return the key
		    # Recursive Case: Evaluate locator[0], if node has this key continue recursively with locator[1,length]
		    private		    
		    def find_port(element,locator)
		    	
		    	if(locator.length == 1)
		    		return element[locator[0]]		    		
		    	else
		    		if(element.has_key?locator[0])
		    			key = locator.delete_at(0)
		    			return find_port(element[key],locator)
		    		else
		    			return nil
		    		end
		    	end
		    end

		    # locators is a property that provides info about the relationship between logical entities, and
		    # their roles (and how to find out ports => just in case the attribute of the node was special)
		    # To obtain the service port we'll use a default node[#{v["component"]}]["port"], if a "locator" (Array of keys) is provided, then 
		    # the library will try find a property by node[locator[0]][locator[1]]...locator[n]
		    # Locator's hash is get from databag("node_resolver","config")
		    private 
		    def locators
		    	v = data_bag_item("node_resolver","config")
		    	locators = nil

		    	# See if we have config overriden by environment
		    	if(v.has_key?"override_environment")
		    		# if this environment has element, then use that configuration
		    		if(v["override_environment"].has_key?node.chef_environment)
		    			locators = v["override_environment"][node.chef_environment]
		    		end
		    	end
		    	
		    	# No config for this environment, fallback to default config
		    	if(locators == nil)
		    		locators = v["default"]
		    	end
		    	return locators
		    end
            
            # If some component within the platfform was not launched through chef, we have a databag
            # node_resolver/static_nodes to store information relative to its configuration, so if sometime
            # we migrate that node to chef, we have a quick way to make the change
            private
            def get_static_info(component)
                v = data_bag_item("node_resolver","static_nodes")
                Chef::Log.info v.to_s
                result = nil

                if v!=nil                    
                    if v.has_key?"override_environment"
                        if(v["override_environment"].has_key?node.chef_environment)
                            if(v["override_environment"][node.chef_environment].has_key?component)
                                Chef::Log.info "There are overriden settings for static node for #{node.chef_environment} and component #{component}"
                                return v["override_environment"][node.chef_environment][component]
                            end                    
                        end    
                    end
                    
                    # config for this component for node.chef_environment not found, fallback to default one
                    if(result == nil)
                        Chef::Log.info "Returning default value #{v["default"][component]}"
                        return v["default"][component]
                    end                
                end

                

                return nil
            end

            private
            def is_component_static(component)
                if(locators.has_key?component)
                    return false 
                else
                    return true                   
                end
            end

	end

end
