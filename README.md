## Inception-of-Things
### p1
#### [Our Vagrantfile](https://github.com/bolmos-o/Inception-of-Things/blob/main/p1/Vagrantfile "Vagrantfile")
#### Vagrant configuration
> Subject:
To begin, you have to set up 2 machines.
Write your first Vagrantfile using the latest stable version of the distribution of your choice as your operating system

We will use official [documentation](https://developer.hashicorp.com/vagrant/docs "documentation") if Vagrant and [Available Settings](https://developer.hashicorp.com/vagrant/docs/vagrantfile/machine_settings#config-vm-synced_folder "Available Settings") for respect subject

**All our vagrant files starts with:**
```ruby
Vagrant.configure("2") do |config|
```
**We will use [centos/7](https://app.vagrantup.com/centos/boxes/7 "centos/7") vagrant box:**
```ruby
config.vm.box = "centos/7"
```
Lets share a folder between VM and Host machine:

```ruby
  config.vm.synced_folder "shared/", "/shared", create: true
  ```
  A folder shared/ will be created in Vagrantfile folder if it's not steel created. You can put something inside and use:
  ```console
  vagrant rsync
  ```
  And disable default Vagrant sync folder:
  ```ruby
  config.vm.synced_folder ".", "/vagrant", disabled: true
```

#### Each server configuration

> Subject: The machine names must be the login of someone of your team. The hostname of the first machine must be followed by the capital letter S (like Server). The hostname of the second machine must be followed by SW (like ServerWorker).

We define servers in differents blocks like:
```ruby
  config.vm.define "bolmos-oS" do |server|
  config.vm.define "bolmos-oSW" do |serverWorker|
```
and setting hostnames:
```ruby
    server.vm.hostname = "bolmos-oS"
    serverWorker.vm.hostname = "bolmos-oSW"
```
Every block (**do** keyword) must be closed with **end** keyword.

Then we will set up vm CPU, RAM, disk space and networks:

> Subject:
 It is STRONGLY advised to allow only the bare minimum in terms of resources: **1 CPU, 512 MB of RAM (or 1024).** The machines must be run using Vagrant.
 
 >Subject:
 • Have a dedicated IP on the eth1 interface. The IP of the first machine (**Server**) will be **192.168.42.110**, and the IP of the second machine (**ServerWorker**) will be **192.168.42.111**

```ruby
server.vm.network "private_network", ip: "192.168.42.110"
	server.vm.provider "virtualbox" do |vb|
	vb.name = "bolmos-oS"
	vb.memory = 512
	vb.cpus = 1
```
and for **bolmos-oSW**:
```ruby
ip: "192.168.42.111"
```
#### k3s installation
> Subject:
You must install K3s on both machines:
• In the first one (Server), it will be installed in controller mode.
• In the second one (ServerWorker), in agent mode.

First machine [k3s](https://docs.k3s.io/installation/requirements "k3s") installation:
```ruby
server.vm.provision "shell", inline: <<-SHELL
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 192.168.42.110" K3S_KUBECONFIG_MODE="644" sh -
	cp /var/lib/rancher/k3s/server/node-token /shared/ 
SHELL
```
Second:
```ruby
serverWorker.vm.provision "shell", inline: <<-SHELL
	while [ ! -f /shared/node-token ]; do
		sleep 2
	done
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 192.168.42.111" K3S_URL=https://192.168.42.110:6443 K3S_TOKEN=$(cat /shared/node-token) sh -      
	rm /shared/node-token
SHELL
```

#### Usage
Then you can launch your Vagrant file using:

```console
vagrant up
```

and check runned VM's:
```console
vagrant status
```

> Current machine states:

> bolmos-oS                 running (libvirt)

> bolmos-oSW                running (libvirt)

> This environment represents multiple VMs. The VMs are all listed
> above with their current state. For more information about a specific
> VM, run `vagrant status NAME`.

To connect to VM use:
```console
vagrant ssh $vm_name
```
like:
```console
vagrant ssh bolmos-oS
vagrant ssh bolmos-oSW
```

# NEED TO FINISH "You will have to use kubectl (and therefore install it too)." and test file in school pc. don't work correctly on MY PC
