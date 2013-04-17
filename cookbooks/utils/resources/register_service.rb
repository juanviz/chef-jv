# Cookbook Name:: tar
# Recipe:: default
# Resource:: tar
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

actions :register

attribute :name, :kind_of => String, :name_attribute => true

def initialize(*args)
  super
  @action = :download
end





