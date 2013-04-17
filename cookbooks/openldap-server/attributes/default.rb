

default['openldap_server']['installer']['dir'] = "/opt/jv/"
default['openldap_server']['installer']['version'] = ''
default['openldap_server']['installer']['name'] = "LDAP" + default['openldap_server']['installer']['version'] + ".tar.gz"
default['openldap_server']['installer']['file']['url'] = '/lite-env/ldap/' + default['openldap_server']['installer']['name']


default['openldap_server']['schema']['url'] = "/lite-env/ldap/schema.tar.gz" 
default['openldap_server']['ldif']['url'] = "/lite-env/ldap/stable_all.ldiff"

default['ldap']['user'] = "root"
default['ldap']['group'] = "root"


