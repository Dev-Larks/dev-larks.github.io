---
title:  "Using libvirt to Assign Static IP Addresses to Vagrant VMs"
date:   2022-02-16 20:29:42
categories: [linux]
tags: [linux, vagrant, libvirt, ansible]
---


I've spent the last month beginning to learn about Ansible as a configuration management tool, I've been using Vagrant to create virtual machines that I can then run Ansible adhoc commands and playbooks against. My test environment is using Vagrant to provision VMs using libvirt as the default provider. I've been committing the various playbooks to source control and had run into the problem where when using vagrant up to recreate virtual machines at a later date I have to manually update the hosts file in the playbook folder to reflect the IP address details of the new VM. 

As the configuration examples from my resources became more complex I reached a point where I needed to be able to define in advance an IP address when running 'vagrant up'. By default libvirt assigns a DHCP address when the VM is brought up.  I'd read through the official Vagrant documentation but was unable to achieve what I wanted, I'd also read through the libvirt documentation but again could configure a solution that worked. This post outlines the process that I followed to to assign persitant static IP addresses to Vagrant virtual machines.

By default libvirt creates the vagrant-libvirt network when the 'vagrant up' command is executed, this network is not persistent and is removed when you execute vagrant destroy. The first step in my solution was to create a new network. Libvirt provides the virsh command line tool, using this tool I was able to dump out the configuration of the vagrant-libvirt network to the terminal.

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

After destroying the VM I then modified the output changing the bridge name to 'virbr1' andthe IP address to the 10.44.93.0 subnet and saved the file as vagrant-libvirt-net.xml. The virsh net-define command was executed to add the network, the .xml configuration file being written to /etc/libvirt/qemu/networks/. However the new network is not active and is not set to autostart this is amended with the virsh net-start and virsh net-autostart commands.

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

This completed network configuration then provides a platform where by defining the VMs mac address in both the Vagrantfile and within the vagrant-libvirt.xml network configuration file will allow for a specific IP address to be defined meeting my use case for Ansible.

