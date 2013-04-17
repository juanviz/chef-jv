mongo_script = template "shard_keys_script" do
	source "shard_keys.erb"
	variables( { :shard_keys => node[:mongodb][:shard_keys] } )
end

include_recipe "mongodb::run_mongo_script"
