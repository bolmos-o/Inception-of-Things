# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-11"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "4096"
	vb.cpus = 6
	vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
	vb.customize ["modifyvm", :id, "--vram", "32"]
  end

  config.vm.provision "shell", inline: <<-SHELL
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	wget https://download.virtualbox.org/virtualbox/7.0.4/virtualbox-7.0_7.0.4-154605~Debian~bullseye_amd64.deb
	apt update && apt install -y xfce4 vagrant linux-headers-5.10.0-16-amd64 ./virtualbox-7.0_7.0.4-154605~Debian~bullseye_amd64.deb
	echo '* 192.168.0.0/16' > /etc/vbox/networks.conf
  SHELL
end
