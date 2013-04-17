################################################################################
# File server parameters. By default (true), uses data_bag configured file
# server (in public subnet). For staging/prod, the env. will override the  
# value with a local file server.
################################################################################

default['mongodb']['fileserver-databag'] = "true"
default['mongodb']['local-fileserver-url'] = ""

################################################################################
# General parameters valid for all types of node (db, config, arbitrer):
################################################################################

default['mongodb']['user'] = "jv"
default['mongodb']['group'] = "jv"
default['mongodb']['url'] = "/installers/mongodb/mongodb-linux-x86_64-2.2.2.tgz"
default['mongodb']['install']['path'] = "/opt/jv/dbs"
default['mongodb']['launcher'] = "/opt/jv/dbs/mongodb-linux-x86_64-2.2.2/bin/mongod"
default['mongodb']['log']['dir'] = "/opt/jv/logs"
default['mongodb']['fs']['path'] = "/opt/jv/data/db"
default['mongodb']['data']['path'] = "/opt/jv/data"
default['mongodb']['service']['name'] = "mongodb.sh"
default['mongodb']['service']['auto_start'] = true 


################################################################################
# Parameters that depend on the type of node (db, config, arbitrer):
# - Default values are asumed for mongo db. 
# - Roles "mongodb-config" and "mongodb-arbitrer" overwrite one or more of 
#   the the following values, according to their required startup configuration.
################################################################################

default['mongodb']['log']['name'] = "mongodb.log"
default['mongodb']['port'] = "27017"
default['mongodb']['config']['mode'] = ""
default["mongodb"]["replica-set"]["mode"] = "db"
default['mongodb']['replica-set']['name'] = "smp"

#################################################################
# Parameters to configure RAID
#################################################################
default["mongodb"]["raid"]["diskcount"] = 2
# Disk size in Gb
default["mongodb"]["raid"]["disksize"] = 1

##################################################################
# Mongo Config Node prefix name. 
# Prefix name for mongo configs instances, it will be used to add them to etc/hosts file. 
# Has array that contains the search term used => the prefix used to add them to etc/hosts
##################################################################
default["mongodb"]["config-node-prefix"] = {
"role:mongodb-config" => "mongoconfig",
    "role:mongodb-arbitrer" => "mongoarbit",
    "role:mongodb" => "mongodb-"}

default["mongodb"]["shard_keys"] = {}
