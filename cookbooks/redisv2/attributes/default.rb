############################### ULIMIT CONFIG ################################

default['redis']['user-ulimits']['soft-nofile'] = "jv	soft	nofile	35000"
default['redis']['user-ulimits']['hard-nofile'] = "jv	hard	nofile	35000"

############################### BASICS CONFIG ################################

default['redis']['conf']  = "/opt/jv/redis/redis.conf"
default['redis']['user']  = "jv"
default['redis']['daemonize'] = "no"
default['redis']['pidfile'] = "/opt/jv/redis/redis.pid"
default['redis']['port'] = "6379"
default['redis']['connection']['timeout'] = "0"
## default['redis']['loglevel'] = "warning"           ------------------------> put as data bag
default['redis']['logfile'] = "/opt/jv/logs/redis.log"

## Syslog variables we currently commented in the conf file.
default['redis']['syslog']['enabled'] = "no"
default['redis']['syslog']['ident'] = "redis"
## default['redis']['syslog']['facility'] = "local0"           ------------------------> put as data bag
##
default['redis']['databases'] = "16"

################################ SNAPSHOTTING #################################

#   Save the DB on disk: after 900 sec (15 min) if at least 1 key changed
#   Save the DB on disk: after 300 sec (5 min) if at least 10 keys changed
#   Save the DB on disk: after 60 sec if at least 10000 keys changed
default['redis']['database']['saves'] = ["900 1","300 10","60 10000"]

default['redis']['stop-write']['bgsafe-error'] = "yes"
default['redis']['rdbcompression'] = "yes"
default['redis']['rdbchecksum'] = "yes"
default['redis']['dbfilename'] = "dump.rdb"
default['redis']['dir'] = "/opt/jv/dbs"

################################# REPLICATION #################################

# The next line must be ommented for the Master:
default['redis']['slaveof'] = "# slaveof <masterip> <masterport>"

default['redis']['masterauth'] = "<master-password>"

default['redis']['slave']['serve-stale-data'] = "yes"
default['redis']['slave']['read-only'] = "yes"

default['redis']['repl']['ping']['slave']['period'] = "10"
default['redis']['repl']['timeout'] = "60"

default['redis']['slave']['priority'] = "100"

################################## SECURITY ###################################

default['redis']['requirepass'] = "foobared"
default['redis']['rename']['command'] = "CONFIG """

################################### LIMITS ####################################

default['redis']['maxclients'] = "10000"
default['redis']['maxmemory'] = "<bytes>"
default['redis']['maxmemory-policy'] = "volatile-lru"
default['redis']['maxmemory-samples'] = "3"

############################## APPEND ONLY MODE ###############################

default['redis']['appendonly'] = "no"
default['redis']['appendfilename'] = "appendonly.aof"
default['redis']['appendfsync'] = "everysec"
### Other appendfsync possible values: "always", "no"

default['redis']['no-appendfsync-on-rewrite'] = "no"
default['redis']['auto-aof-rewrite']['percentage'] = "100"
default['redis']['auto-aof-rewrite']['min-size'] = "64mb"

################################ LUA SCRIPTING  ###############################

default['redis']['lua-time']['limit'] = "5000"

################################## SLOW LOG ###################################

default['redis']['slowlog']['log-slower-than'] = "10000"
default['redis']['slowlog']['max-len'] = "128"

############################### ADVANCED CONFIG ###############################

default['redis']['hash-max']['ziplist-entries'] = "512"
default['redis']['hash-max']['ziplist-value'] = "64"

default['redis']['list-max']['ziplist-entries'] = "512"
default['redis']['list-max']['ziplist-value'] = "64"

default['redis']['set-max']['intset-entries'] = "512"

default['redis']['zset-max']['ziplist-entries'] = "128"
default['redis']['zset-max']['ziplist-value'] = "64"

default['redis']['activerehashing'] = "yes"

default['redis']['client']['output-buffer-limit']['normal'] = "normal 0 0 0"
default['redis']['client']['output-buffer-limit']['slave'] = "slave 256mb 64mb 60"
default['redis']['client']['output-buffer-limit']['pubsub'] = "pubsub 32mb 8mb 60"

################################## INCLUDES ###################################

default['redis']['include']['conf-file'] = "/path/to/file.conf"
