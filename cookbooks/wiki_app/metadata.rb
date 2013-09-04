maintainer       "Juan Vicente Herrera"
maintainer_email "juan.vicente.herrera@gmail.com"
license          "GPL"
description      'Installs/Configures wiki_app, MediaWiki based'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends          "apache2"
depends          "mysql"
depends 	"database"
depends		"s3_file"
