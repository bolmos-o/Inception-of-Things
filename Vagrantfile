# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-11"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "8192"
	vb.cpus = 12
	vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
	vb.customize ["modifyvm", :id, "--vram", "64"]
  end

  config.vm.provision "shell", inline: <<-SHELL
	# vagrant, virtualbox, xfce, firefox, git, vim
 	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	wget https://download.virtualbox.org/virtualbox/7.0.4/virtualbox-7.0_7.0.4-154605~Debian~bullseye_amd64.deb
	apt-get update && apt-get install -y xfce4 firefox-esr vim vagrant linux-headers-$(uname -r) ./virtualbox-7.0_7.0.4-154605~Debian~bullseye_amd64.deb
	# docker
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
	usermod -aG docker vagrant
	# kubectl
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	cat >> /home/vagrant/.bashrc << EOF
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
	# k3d
	wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	# helm
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
	# update /etc/hosts
	echo '127.0.0.1 gitlab.example.com' >> /etc/hosts
	SHELL

end
