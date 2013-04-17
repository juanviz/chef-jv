execute "run_mongo_script" do
	path "/opt/jv/dbs/mongodb"
	command "mongo --eval '#{mongo_script}'"
end
