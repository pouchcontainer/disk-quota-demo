# vim: set filetype=ruby:

VAGRANTFILE_API_VERSION = "2"

# extraDisk is used for disk quota functionality.
extraDisk = "data/extraDisk.vdi"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/ubuntu-18.04"

  # provided by virtualbox
  #
  # - headless bootup
  # - 4 cpu number
  # - 4GB memory
  # - add 20G extra disk
  config.vm.provider "virtualbox" do |vb|
    vb.gui    = false
    vb.cpus   = 4
    vb.memory = 4096

    # add new disk into box
    if !File.exist?(extraDisk)
      vb.customize [
        'createhd',
        '--filename', extraDisk,
        '--size', 20 * 1024
      ]
    end

    # NOTE: the storage controller depends on the distro of ubuntu
    vb.customize [
      'storageattach', :id,
      '--storagectl', 'SATA Controller',
      '--port', 2, 
      '--type', 'hdd',
      '--medium', extraDisk
    ]
  end

  # setup package source
  config.vm.provision "shell", :path => "build/pkg_mgmt.sh"

  # install tools
  config.vm.provision "shell", :path => "build/install_tools.sh"

  # setup fstab so that box still has the extra disk after reboot
  config.vm.provision "shell", :path => "build/setup_extra_disk.sh"
end
