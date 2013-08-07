# Currently we are using role's env_run_list parameter as a rule to create roles
# Roles are just logical entities in our platfform, and their run_lists should be consistent
# across environments. env_run_list should be used only for special cases. 
# 
# This script moves the staging's/production env_run_lists to the default one (run_list attribute). At the end of this step only the _default run_list will be let as available
#
# Author:: José Manuel Felguera mailto:jmfelguer@reacciona.es)    
# Copyright:: Copyright (c) 2013 Lumata Spain

roles.all.each do |role|
    if role.env_run_list.keys.length > 1
         env = "staging"
         if role.env_run_list.has_key?"production"
            env = "production"
         end
         role.env_run_list["_default"] = role.env_run_list[env]
         # delete all env_run_lists (except the _default one)
         role.env_run_list.each do |k,v|
             if k != "_default"
                 role.env_run_list.delete(k)
             end
         end
         # save role
         role.save
         puts "Role #{role.name} modified. Run_list replaced by env_run_list[#{env}] " 
    end
end
