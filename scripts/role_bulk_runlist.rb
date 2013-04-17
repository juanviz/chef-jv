#
# Author: Juan Vicente Herrera Ruiz de Alejo
#
# This script  can perform bulk operations over run_lists of roles 
#
# *Args:*
#
#   - [0] = Action to be executed (add or delete)
#   - [1] = Role's Search term => in chef search notation
#   - [2] = elemnts to be added => Ex: "role[x],recipe[k]"
#   - [3](optional) = run_list to be added, if not provided, the _default one is used
#

help = 'usage: knife exec role_bulk_run_list ACTION "SEARCH_TERM" "RUN_LIST_ITEMS" RUN_LIST_ENV)
       ACTION :       Action to be executed over the role\'s run_list. 
                      Available actions are add or delete
       SEARCH_TERM:   Search term to find out the roles to be modified
       RUN_LIST_ITEMS:List of items to be added, ie: recipe[x] or role[y]. 
                      You can use a comma separated list of items
       RUN_LIST_ENV (optional): Optional environment run_list. 
                      If not provided, default is used      
      '



abort(help) unless (ARGV[2] and ARGV[3] and ARGV[4])
action = ARGV[2]

unless( ["add","delete"].include?action )
    abort("Unknow action: #{action}")
end

    
search_term = ARGV[3]
run_list_entries = ARGV[4].split(",")
run_list_env = ARGV[5]

if(run_list_env == nil)
    run_list_env = "_default"
end

# Search roles in chef
roles_result = search(:role,"#{search_term}")

roles_result.each do |r|
     
     run_list_entries.each do |i|
            case action
            when "add"
                 r.env_run_list[run_list_env] << i
            when "delete"
                 r.env_run_list[run_list_env].delete(i)
            end
     end
     r.save
     puts "Run List entry succesfully modified (#{action}) to role #{r.name} (run_list => #{run_list_env})"  
end
exit 0
