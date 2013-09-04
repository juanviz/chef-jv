wiki_app Cookbook
=================

This cookbook install a MediaWiki github repository and import a dump in the MySQL database from s3.
LocalSettings.php variables are filled with values included in encrypted databags and attributes from environment file.

Requirements
------------

Cookbooks:

Apache2

MySQL

s3_file

PHP

Database

Attributes
----------
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['wiki_app']['db_user']</tt></td>
    <td>String</td>
    <td>the user that uses the app to connect to MySQL database</td>
    <td><tt>wikijv</tt></td>
  </tr>

 <tr>
    <td><tt>['wiki_app']['db_name']</tt></td>
    <td>String</td>
    <td>the database that have the MediaWiki scheme</td>
    <td><tt>wikijv</tt></td>
  </tr>
 <tr>
    <td><tt>['wiki_app']['db_host']</tt></td>
    <td>String</td>
    <td>ip or name of the database instance</td>
    <td><tt>127.0.0.1</tt></td>
  </tr>
 <tr>
    <td><tt>['wiki_app']['server_name']</tt></td>
    <td>String</td>
    <td>url of the site used in virtualhost configuration</td>
    <td><tt>wiki.juanvicenteherrera.es</tt></td>
  </tr>
 <tr>
    <td><tt>['wiki_app']['docroot']</tt></td>
    <td>String</td>
    <td>Apache docroot</td>
    <td><tt>/var/www</tt></td>
  </tr>

<tr>
    <td><tt>['wiki_app']['config_dir']</tt></td>
    <td>String</td>
    <td>folder of the main configuration file Localsettings.php </td>
    <td><tt>/var/www/current</tt></td>
  </tr>

<tr>
    <td><tt>['wiki_app']['deploy_repo']</tt></td>
    <td>String</td>
    <td>Github repository to deploy</td>
    <td><tt>/var/www</tt></td>
  </tr>

<tr>
    <td><tt>['wiki_app']['deploy_branch']</tt></td>
    <td>String</td>
    <td>branch to deploy</td>
    <td><tt>HEAD</tt></td>
  </tr>

<tr>
    <td><tt>['wiki_app']['deploy_dir']</tt></td>
    <td>String</td>
    <td>Folder for deploy the app</td>
    <td><tt>/var/www</tt></td>
  </tr>
<tr>
    <td><tt>['wiki_app']['seed_file']</tt></td>
    <td>String</td>
    <td>local path to store the s3 dump in the database server</td>
    <td><tt>/tmp/wikijv.sql</tt></td>
  </tr>
<tr>
    <td><tt>['wiki_app']['bucket']</tt></td>
    <td>String</td>
    <td>S3 bucket where is located the mysql dump that you want to import in database</td>
    <td><tt>wikijv</tt></td>
  </tr>
<tr>
    <td><tt>['wiki_app']['bucket_file']</tt></td>
    <td>String</td>
    <td>name of the s3 MySQL dump file</td>
    <td><tt>wikijv.sql</tt></td>
  </tr>
<tr>
    <td><tt>['wiki_app']['web_host']</tt></td>
    <td>String</td>
    <td>elastic ip or dns name of web instance</td>
    <td><tt>127.0.0.1</tt></td>
  </tr>


	</table>

Usage
-----
#### wiki_app::default

I suggest create 2 roles:

webserver.json

```json
{
"env_run_lists":{},
"default_attributes":{},
"name":"webserver",
"run_list":["role[base]",
  "recipe[php]",
  "recipe[php::module_mysql]",
  "recipe[wiki_app]"
],
"json_class":"Chef::Role",
"override_attributes":{},
"description":"Staging environment",
"chef_type":"role"
}
```

db.json

```json
{
"env_run_lists":{},
"default_attributes":{},
"name":"db",
"run_list":["recipe[mysql::server]","role[base]","recipe[wiki_app::db_master]"],
"json_class":"Chef::Role",
"override_attributes":{},
"description":"Staging environment",
"chef_type":"role"
}

```

Ensure change elastic ips of your db instance and your web instance in environment file:

```json
{
"name": "prod",
"description": "The production environment",
"override_attributes":{
"wiki_app": {
            "db_host": "107.21.114.177",
	    "web_host": "54.221.195.143"
        }
}
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: 

Juan Vicente Herrera Ruiz de Alejo @jvicenteherrera

License:

Apache License v2.0 

http://www.apache.org/licenses/GPL-compatibility.html
