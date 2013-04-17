# Cookbook Name:: utils
# Recipe:: default
# Resource:: download
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

actions :download

attribute :dest_dir, :kind_of => String, :name_attribute => true
attribute :owner, :kind_of => String, :default => "root"
attribute :group, :kind_of => String, :default => "root"
attribute :source, :kind_of => String,:default => ""

def initialize(*args)
  super
  @action = :download
end





