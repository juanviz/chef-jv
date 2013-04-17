name              "java"
maintainer        "jJuan Vicente Herrear
maintainer_email  "juan.vicente.herrera@gmail.com"
description       "Installs Java 1.6.0_13 from local oracle file."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"

recipe "java", "Installs Java runtime"

%w{ debian ubuntu centos redhat scientific fedora amazon arch freebsd }.each do |os|
  supports os
end
