#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)
# Cookbook Name:: java
# Attributes:: default
#

#
# Download remote files from file server (configured in Chef:;Config[file_cache_path)
#

default['java']['jdk-6u13-64']['url'] = "/installers/jdk-6u13-linux-amd64.rpm"
default['java']['java_home'] = "/usr/java/default"
