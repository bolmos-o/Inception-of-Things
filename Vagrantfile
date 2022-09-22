# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-11"
  
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.cpus = 8
    vb.memory = 8192
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"] 
    vb.customize ["modifyvm", :id, "--vram", "64"] 
  end

  config.vm.provision "shell", inline: <<-SHELL
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --output /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee /etc/apt/sources.list.d/oracle.list
    apt-get update
    apt-get install -y linux-headers-5.10.0-16-amd64 xfce4 vagrant virtualbox-6.1
    echo '* 192.168.0.0/16' > /etc/vbox/networks.conf
  SHELL
end
