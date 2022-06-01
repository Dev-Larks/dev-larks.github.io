---
title:  "Using libvirt to Assign Static IP Addresses to Vagrant VMs"
date:   2022-03-05 10:40:42
categories: [Linux]
tags: [Linux,Vagrant,Libvirt,Ansible]
---


I've spent the last month beginning to learn about Ansible as a configuration management tool, I've been using Vagrant to create virtual machines that I can then run Ansible adhoc commands and playbooks against. My test environment is using Vagrant to provision VMs using libvirt as the default provider. I've been committing the various playbooks to source control and had run into the problem where when using vagrant up to recreate virtual machines at a later date I have to manually update the hosts file in the playbook folder to reflect the IP address details of the new VM. 

As the configuration examples from my resources became more complex I reached a point where I needed to be able to define in advance an IP address when running 'vagrant up'. By default libvirt assigns a DHCP address when the VM is brought up.  I'd read through the official Vagrant documentation but was unable to achieve what I wanted, I'd also read through the libvirt documentation but again could not configure a solution that worked. This post outlines the process that I followed to to assign persistant static IP addresses to Vagrant virtual machines.

By default libvirt creates the vagrant-libvirt network when the 'vagrant up' command is executed, this network is not persistent and is removed when you execute vagrant destroy. The first step in my solution was to create a new network. Libvirt provides the virsh command line tool, using this tool I was able to write out the configuration of the vagrant-libvirt network to the terminal.

virsh net-dumpxml vagrant-libvirt

```powershell
<network connections='1' ipv6='yes'>
  <name>vagrant-libvirt</name>
  <uuid>18089b69-ee5b-4b6a-822e-e52351b3186a</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:41:c0:62'/>
  <ip address='192.168.121.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.121.1' end='192.168.121.254'/>
    </dhcp>
  </ip>
</network>
```

After destroying the Vagrant VM I then modified the output of the virsh net-dumpxml command, changing the bridge name to 'virbr1' and the IP address to the 10.44.93.0 subnet and saved the file as vagrant-libvirt-net.xml. The virsh net-define command was executed to add the network, the .xml configuration file being written to /etc/libvirt/qemu/networks/. However the new network in this default state is not active and not set to autostart the default configuration was amended with the virsh net-start and virsh net-autostart commands.

```powershell
[craig][~/Dev/Vagrant]-> virsh net-define vagrant-libvirt-net.xml
Network vagrant-libvirt defined from vagrant-libvirt-net.xml
[craig][~/Dev/Vagrant]->
[craig][~/Dev/Vagrant]-> ls /etc/libvirt/qemu/networks/
autostart  vagrant-libvirt.xml
[craig][~/Dev/Vagrant]-> virsh net-start vagrant-libvirt
Network vagrant-libvirt started

[craig][~/Dev/Vagrant]-> virsh net-autostart vagrant-libvirt
Network vagrant-libvirt marked as autostarted

[craig][~/Dev/Vagrant]-> virsh net-list --all
 Name              State    Autostart   Persistent
----------------------------------------------------
 vagrant-libvirt   active   yes         yes
```

This network configuration then provides a platform where by defining the VMs mac address in both the Vagrantfile and within the vagrant-libvirt-net.xml network configuration file will allow for a specific IP address to be defined for a VM meeting my use case for Ansible. Executing the 'virsh net-update' and specifying the network to target and the mac address and desired ip address to assign to it allows you to define as many DHCP reservations as you need. The output below shows the reservation saved to the vagrant-libvirt network configuration.

```powershell
[craig][~]-> virsh net-update vagrant-libvirt add-last ip-dhcp-host '<host mac="52:54:00:00:01:01" ip="10.44.93.100"/>' --live --config --parent-index 0
Updated network vagrant-libvirt persistent config and live state
[craig][~]-> virsh net-dumpxml vagrant-libvirt
<network>
  <name>vagrant-libvirt</name>
  <uuid>3e1d0707-c92c-474d-87a5-87a35719eb1b</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:16:a9:cb'/>
  <ip address='10.44.93.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.44.93.2' end='10.44.93.254'/>
      <host mac='52:54:00:00:01:01' ip='10.44.93.100'/>
    </dhcp>
  </ip>
</network>
```
An example Vagrantfile which creates three virtual machines using predefined host mac addresses is shown below.

```powershell
Vagrant.configure("2") do |config|
  # Use the same ssh key for each machine
  config.ssh.insert_key = false

  config.vm.define "vagrant1" do |vagrant1|
    vagrant1.vm.box = "generic/ubuntu2004"
    vagrant1.vm.network "forwarded_port", guest: 80, host: 8080
    vagrant1.vm.network "forwarded_port", guest: 443, host: 8443
    vagrant1.vm.provider :libvirt do |domain|
      domain.management_network_mac = "52:54:00:00:01:01"
    end
  end
  config.vm.define "vagrant2" do |vagrant2|
    vagrant2.vm.box = "generic/ubuntu2004"
    vagrant2.vm.network "forwarded_port", guest: 80, host: 8081
    vagrant2.vm.network "forwarded_port", guest: 443, host: 8444
    vagrant2.vm.provider :libvirt do |domain|
      domain.management_network_mac = "52:54:00:00:01:02"
    end
  end
  config.vm.define "vagrant3" do |vagrant3|
    vagrant3.vm.box = "generic/ubuntu2004"
    vagrant3.vm.network "forwarded_port", guest: 80, host: 8082
    vagrant3.vm.network "forwarded_port", guest: 443, host: 8445
    vagrant3.vm.provider :libvirt do |domain|
      domain.management_network_mac = "52:54:00:00:01:03"
    end
  end
end
```
### Conclusion
This solution has greatly simplified the process to create Vagrant VMs when testing with Ansible and removes the need to edit existing Ansible configuration files each time the environment is brought up to reflect the new IP configuration applied to the VM.

#### Sources
Below are links to the documentation and blog posts that I referenced to arrive at this solution:

- Brad Searle - Using The Libvirt Provider With Vagrant [Blogpost](https://codingpackets.com/blog/using-the-libvirt-provider-with-vagrant/)
- Brad Searle - Controlling Vagrant Box Management IP [Blogpost](https://codingpackets.com/blog/controlling-vagrant-box-management-ip/)
- Libvirt [Documentation](https://libvirt.org/sources/virshcmdref/html/)
- Vagrant [Documentation](https://www.vagrantup.com/docs/networking/private_network)

