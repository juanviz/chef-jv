require File.expand_path('~/.chef/aws_credentials_jv.rb')

environment_id = ENV['environment']
if(environment_id.nil? or environment_id.empty?)
 
  print "You need to especify an environment (e.g. environment=qa vagrant ..)\n"
  exit 1
end

print "Running Vagrant for environment #{environment_id}\n"

Vagrant.configure("2") do |config|
config.butcher.knife_config_file = File.expand_path("knife.rb")

#JV configuration
access_key_id=@access_key_id
secret_access_key=@secret_access_key
ami="ami-3ad1af53"
private_key=File.expand_path("~/keypairs/bq.pem")
keypair_name="bq"
box="dummy"
ssh_username="ec2-user"
# AWS data #

# Chef Data #
chef_server_url = "https://api.opscode.com/organizations/juanvi"
validation_key_path = File.expand_path("~/.chef/juanvi-validator-new.pem")
validation_client_name = "juanvi-validator"
# Chef Data #
if (environment_id =~ /^(prod|qa|dev|demo)$/)
# web server #     
 config.vm.define "#{environment_id}-ws" do |web|
    web.vm.box = box
 #   web.omnibus.chef_version = "11.6.0"
    web.vm.provider :aws do |aws, override|
      aws.keypair_name = keypair_name
      aws.access_key_id=access_key_id
      aws.secret_access_key=secret_access_key
      aws.ami = ami
      aws.instance_type = "t1.micro"
      aws.security_groups = ["web","default"]
      override.ssh.username = ssh_username
      override.ssh.private_key_path = private_key
      
      aws.tags = {
      'Name' => "#{environment_id}-web"
    }
    end
    web.vm.provision :chef_client do |chef|
      chef.encrypted_data_bag_secret_key_path = "/Users/juanvi/.chef/encrypted_data_bag_secret"
      chef.chef_server_url = chef_server_url
      chef.validation_key_path = validation_key_path
      chef.validation_client_name = validation_client_name
      #  Provision with the database role
      chef.add_role("webserver")
      # Set the environment for the chef server
      chef.environment = "#{environment_id}"
      chef.node_name = "#{environment_id}-web"
    end
  end

config.vm.define "#{environment_id}-db" do |db|
    db.vm.box = box
    #db.omnibus.chef_version = "11.6.0"
    db.vm.provider :aws do |aws, override|
      aws.keypair_name = keypair_name
      aws.access_key_id=access_key_id
      aws.secret_access_key=secret_access_key
      aws.ami = ami
      aws.instance_type = "t1.micro"
      aws.security_groups = ["MySQL","default"]
      override.ssh.username = ssh_username
      override.ssh.private_key_path = private_key
      aws.elastic_ip = true
        aws.tags = {
      'Name' => "#{environment_id}-db"
    }
    end

    db.vm.provision :chef_client do |chef|
      chef.encrypted_data_bag_secret_key_path = "/Users/juanvi/.chef/encrypted_data_bag_secret"
      chef.chef_server_url = chef_server_url
      chef.validation_key_path = validation_key_path
      chef.validation_client_name = validation_client_name
      #  Provision with the database role
      chef.add_role("db")
      # Set the environment for the chef server
      chef.environment = "#{environment_id}"
      chef.node_name = "#{environment_id}-db"
    end
  end
end
end
