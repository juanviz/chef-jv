default['rabbitmq-server']['listen_port'] = "5672"
default['rabbitmq-server']['rabbitmqadmin_url'] = "/lite-env/rabbitmq/rabbitmqadmin.py"
default['rabbitmq-server']['tgz_package_url'] = "/lite-env/rabbitmq/rabbitmq4amazonlinux.tgz"
default['rabbitmq-server']['mochiweb']['listen_port'] = "55555"
default['rabbitmq-server']['collect_statistics_interval'] = "10000" 
default['rabbitmq-server']['broker_definitions_url'] = "/lite-env/rabbitmq/rabbitMQ_schema_2012-10-8_with_capture_events.json"
default['rabbitmq-server']['user'] = "rabbitmq"

#################################################################
# EBS CONFIGURATION
#
# Munt point for the data EBS:
default['rabbitmq-server']['data']['path'] = "/opt/jv"
# Size and RAID definitions:
default['rabbitmq-server']["raid"]["diskcount"] = 2
default['rabbitmq-server']["raid"]["disksize"] = 25
#################################################################
