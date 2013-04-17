module ProcessHelper
	class << self
################################################################
################################################################
# HELPER METHODS
################################################################

		def helper_kill_process(pid)
			if !pid.empty?
				pid = pid.gsub(/\n\r+/, " ")
				pid_array = pid.split(" ")
				Chef::Log.info "Process to kill: #{pid_array}"
				if pid_array.kind_of?(Array)
					pid_array.each { |x| 
						Process.kill("KILL",x.to_i)
					}
				else
					Process.kill("KILL",x.to_i)
				end
				Chef::Log.info "The process " + pid.gsub(/\s+/, " ").strip + " was killed"
			else
				Chef::Log.info "No process to kill"
			end
		end

		def helper_get_pid_by_name(name)
			Chef::Log.info "Looking process #{name}"
			pid =  `jps -l -m | grep '.'#{name}'.' |  awk -F ' ' '{print $1}'`
			return pid
		end
	end
end
Chef::Recipe.send(:include,ProcessHelper)