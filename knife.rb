current_dir = File.dirname(__FILE__)
cookbook_copyright       "Juan Vicente Herrera Ruiz de Alejo"
cookbook_email           "juan.vicente.herrera@gmail.com"
cookbook_license         "apachev2"
log_level                :info
log_location             STDOUT
node_name                "juanviz"
client_key		"/Users/juanvi/.chef/juanviz.pem"
validation_client_name   "juanvi-validator"
validation_key		   "/Users/juanvi/.chef/juanvi-validator-new.pem"
chef_server_url          "https://api.opscode.com/organizations/juanvi"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path ['/Users/juanvi/chef-repo/cookbooks','/Users/juanvi/repositories/chef-jv/cookbooks/']
encrypted_data_bag_secret "#{current_dir}/encrypted_data_bag_secret"
