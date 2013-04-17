include Opscode::Aws::Ec2


#Auto locates and attached ebs devices based on the data bag they reside in. The following test cases need to be performed
# Create multiple resources with new node: PASS
#
# Re-attach multiple resources after a reboot: PASS
#
# Create resources across 2 runs.  First run creates first raid set, second run re-attaches then creates: PASS
# 
# Re-attach a different nodes data after terminating the original creator: Partial pass.  Does not rename data bag correctly
# Author: Todd Nine
action :auto_attach do
  
  Chef::Log.info("Executing the autolocate task")
  
  #Make sure the mdadm package is installed
  package "mdadm" do
    action :install
  end
  
  package "xfsprogs" do
    action :install
  end
  
  
  
  #we're done we successfully located what we needed
  if !locate_and_mount(@new_resource.mount_point)
    
    #If we get here, we couldn't auto attach, nor re-allocate an existing set of disks to ourselves.  Auto create the md devices
    #Find our first raid device
    number=0
    
    dir = "/dev/md#{number}"
    
    #TODO, this won't work with more than 10 md devices
    begin
      dir = "/dev/md#{number}"
      Chef::Log.info("md pre trim #{dir}")
      number +=1
    end while ::File.exists?(dir)
    
    
    dir = dir[5, dir.length]
    
    Chef::Log.debug("raid device is #{dir}")
    
    
    sd_dev = "sdj"
    
    begin
      sd_dev = sd_dev.next
      base_device = "/dev/#{sd_dev}1"
      Chef::Log.info("dev pre trim #{base_device}")
    end while ::File.exists?(base_device)
    
    Chef::Log.debug("sd device is #{sd_dev}")
    
    create_raid_disks(@new_resource.mount_point, dir, sd_dev, @new_resource.disk_count, @new_resource.disk_size)
    
    @new_resource.updated_by_last_action(true)
    
  end
  
  
  
  
  
end


private

#Attempt to find an unused data bag and mount all the EBS volumes to our system
def locate_and_mount(mount_path )
  
  if node[:aws].nil? || node[:aws][:raid].nil? || node[:aws][:raid][mount_path].nil?
    Chef::Log.info("No mount point found '#{mount_path}' for node")
    return false;
  end
  
  raid_dev =  node[:aws][:raid][mount_path][:raid_dev]
  
  raid_dev = "/dev/#{raid_dev}"
  
  Chef::Log.info("Raid device is #{raid_dev} and mount path is #{mount_path}")
  
  assemble_raid(raid_dev, mount_path)
  
  #Now mount the drive
  mount_device(raid_dev, mount_path)
  
  
  
  return true
  
end

##
#Assembles the raid if it doesn't already exist
##
def assemble_raid(raid_dev, mount_path)
  #D
  if ::File.exists?(raid_dev) 
    Chef::Log.info("Device #{raid_dev} exists skipping")
    return
  end
  
  Chef::Log.info("Raid device #{raid_dev} does not exist re-assembling")
  
  device_vol_map = node[:aws][:raid][mount_path][:devices]
  
  Chef::Log.debug("Devices for mount #{mount_path} are #{device_vol_map.pretty_inspect}")
  
  device_string = ""
  
  device_vol_map.keys.sort.each do |dev_device|
    attach_volume(dev_device, device_vol_map[dev_device])
    device_string += "/dev/#{dev_device} "
  end
  
  #Wait until all volumes are mounted
  ruby_block "wait" do
    block do
     true
    end
  end
  
  #Wait until all volumes are mounted
  ruby_block "wait" do
    block do
      Chef::Log.info("sleeping 10 seconds until EBS volumes have re-attached")
      sleep 10
    end
  end
  
  #Now that attach is done we re-build the md device
  execute "re-attaching raid device" do
    command "mdadm --assemble #{raid_dev} #{device_string}"
    creates raid_dev
    not_if "test -d #{raid_dev}"
    #    notifies :run, "ruby_block[setchanged]", :immediately
  end
end


def mount_device(raid_dev, mnt_point)
  #Create the mount point
  directory mnt_point do
    owner "root"
    group "nogroup"
    mode 0755
    recursive true
    action    :create
    not_if "test -d #{mnt_point}"
    #    notifies :run, "ruby_block[setchanged]", :immediately
  end
  
  
  
  #Mount the device 
  mount mnt_point do
    device raid_dev
    fstype "xfs"
    options "rw,noatime,inode64"
    action :mount
    #    notifies :run, "ruby_block[setchanged]", :immediately
  end
  
end




#Attach all existing ami instances if they exist on this node, if not, we want an error to occur  Detects disk from node information
def attach_volume(disk_dev, volume_id)
  
  disk_dev_path = "/dev/#{disk_dev}"
  
  aws = data_bag_item("aws", "main")
  
  Chef::Log.info("Attaching existing ebs volume id #{volume_id} for device #{disk_dev_path}")
  
  aws_ebs_volume "#{disk_dev_path}" do
    aws_access_key          aws['aws_access_key_id']
    aws_secret_access_key   aws['aws_secret_access_key']
    device                  disk_dev_path
    name                    disk_dev
    volume_id               volume_id
    action                  [:attach]
    provider                "aws_ebs_volume"  
  end
  
  
  
  
end


#Mount point for where to mount I.E /mnt/filesystem
#Raid dev.  I.E. md0
#Diskset    I.E sdi (which creates sdi1-sdi<n>
#Raid size.  The total size of the array
def create_raid_disks(mnt_point, raid_dev, disk_dev, num_disks, disk_size)
  
  #Create the mount point data bag  
  devices = {}
  
  
  #For each volume add information to the mount metadata  
   (1..num_disks).each do |i|
    
    disk_dev_path = "#{disk_dev}#{i}"
    
    aws = data_bag_item("aws", "main")
    
    aws_ebs_volume "#{disk_dev_path}" do
	  Chef::Log.info("creating ebs volume for device #{disk_dev_path} with size #{disk_size}")
	  
      aws_access_key          aws['aws_access_key_id']
      aws_secret_access_key   aws['aws_secret_access_key']
      size                    disk_size
      device                  "/dev/#{disk_dev_path}"
      name                    disk_dev_path
      action                  [:create, :attach]
      provider                "aws_ebs_volume"  
      
      #set up our data bag info
      devices[disk_dev_path] = "pending"
      
    end
    
  end
  
  devices_string = ""
  
  #Blocking task
  
  devices.keys.sort.each do  |k|
    devices_string += "/dev/#{k} "
  end
  
  Chef::Log.debug("finsihed sorting devices #{devices_string}")
  
  Chef::Log.debug("sleeping 20 seconds to let drives attach")
  
  sleep 20
  
  #Create the raid device on our system
  execute "creating raid device" do
    Chef::Log.info("creating raid device /dev/#{raid_dev} with raid devices #{devices_string}")
    command "mdadm --create /dev/#{raid_dev} --level=0 --raid-devices=#{devices.size} #{devices_string}"
    creates "/dev/#{raid_dev}"
  end
  
  #Format the device
  execute "formatting device" do
    command "mkfs.xfs /dev/#{raid_dev}"
    only_if "xfs_admin -l /dev/#{raid_dev} 2>&1 | grep -qx 'xfs_admin: /dev/#{raid_dev} is not a valid XFS filesystem (unexpected SB magic number 0x00000000)'"
  end
  
  #Mount the device
  mount_device("/dev/#{raid_dev}", mnt_point)
  
  #Not invoked until the volumes have been successfully created and attached
  ruby_block "databagsetup" do
    
    block do
      Chef::Log.info("finished creating disks")
      
      
      devices.each_pair do |key, value|
        value = node[:aws][:ebs_volume][key][:volume_id]
        devices[key] =  value
        Chef::Log.info("value is #{value}")
      end
      
      #Assemble all the data bag meta data
      mount_meta = {
        "raid_dev" => raid_dev,
        "devices" => devices
      }
      
      raid_map = node[:aws][:raid]
      
      if raid_map.nil?
        node[:aws][:raid] = {}
      end
      
       Chef::Log.info("Storing raid info in node [aws][raid]")
      node[:aws][:raid][mnt_point] = mount_meta
      node.save
      
    end
  end
  
  #Now format and create the device
  
end
