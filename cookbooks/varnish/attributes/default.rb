default['varnish']['admin']['url'] = "localhost"
default['varnish']['listen']['port'] ="8080"
default['varnish']['admin']['port'] = "6082"
default['varnish']['backend-storage'] = "malloc,2G"
default['varnish']['default-vcl']['path'] = "/etc/varnish/default.vcl"
default['varnish']['sysconfig-varnish']['path'] = "/etc/sysconfig/varnish"
default['varnish']['launcher'] = "/etc/init.d/varnish"
