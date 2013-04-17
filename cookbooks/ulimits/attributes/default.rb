# Name of the ulimits file template:
default['ulimits']['file']['template'] = "limits.conf.erb"

# Ulimit values:
default['ulimits']['soft']['nproc'] = "131072"
default['ulimits']['hard']['nproc'] = "262144"
default['ulimits']['soft']['stack'] = "1024000"
default['ulimits']['soft']['nofile'] = "131072"
default['ulimits']['hard']['nofile'] = "262144"

