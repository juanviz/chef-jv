#
# Cookbook Name:: wiki_app
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'database::mysql'
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "wiki_app::deploy"
include_recipe "wiki_app::webserver"



