include_recipe "wiki_app::webserver" 

# Handle ssh key for git private repo
secrets = Chef::EncryptedDataBagItem.load("secrets", "wiki_app")
if secrets["deploy_key"]
  ruby_block "write_key" do
    block do
      f = ::File.open("#{node['wiki_app']['deploy_dir']}/id_deploy", "w")
      f.print(secrets["deploy_key"])
      f.close
    end
    not_if do ::File.exists?("#{node['wiki_app']['deploy_dir']}/id_deploy"); end
  end

  file "#{node['wiki_app']['deploy_dir']}/id_deploy" do
    mode '0600'
  end

  template "#{node['wiki_app']['deploy_dir']}/git-ssh-wrapper" do
    source "git-ssh-wrapper.erb"
    mode "0755"
    variables("deploy_dir" => node['wiki_app']['deploy_dir'])
  end
end

deploy_revision node['wiki_app']['deploy_dir'] do
  scm_provider Chef::Provider::Git 
  repo node['wiki_app']['deploy_repo']
  revision node['wiki_app']['deploy_branch']
  if secrets["deploy_key"]
    git_ssh_wrapper "#{node['wiki_app']['deploy_dir']}/git-ssh-wrapper" # For private Git repos 
  end
  enable_submodules true
  shallow_clone false
  symlink_before_migrate({}) # Symlinks to add before running db migrations
  purge_before_symlink [] # Directories to delete before adding symlinks
  create_dirs_before_symlink [] # Directories to create before adding symlinks
  symlinks({"/etc/httpd/sites-available/default" => "/etc/httpd/sites-enabled/default.conf"})
  # migrate true
  # migration_command "php app/console doctrine:migrations:migrate" 
  action :deploy
  restart_command do
    service "httpd" do action :restart; end
  end
end
