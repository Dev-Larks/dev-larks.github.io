---
title:  "Using libvirt to Assign Static IP Addresses to Vagrant VMs"
date:   2022-02-16 20:29:42
categories: [linux]
tags: [linux, vagrant, libvirt, ansible]
---


I've spent the last month beginning to learn about Ansible as a configuration management tool, I've been using Vagrant to create virtual machines that I can then run Ansible adhoc commands and playbooks against. My test environment is using Vagrant to provision VMs using libvirt as the default provider. I've been committing the various playbooks to source control and had run into the problem where when using vagrant up to recreate virtual machines at a later date I have to manually update the hosts file in the playbook folder to reflect the IP address details of the new VM. 

As the configuration examples from my resources became more complex I reached a point where I needed to be able to define in advance an IP address when running 'vagrant up'. By default libvirt assigns a DHCP address when the VM is brought up.  I'd read through the official Vagrant documentation but was unable to achieve what I wanted, I'd also read through the libvirt documentation but again could configure a solution that worked. This post outlines the process that I followed to to assign persitant static IP addresses to Vagrant virtual machines.

By default libvirt creates the network when the 'vagrant up' command is executed, this network is not persistent and is removed when you ...
