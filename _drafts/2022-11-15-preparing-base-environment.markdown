---
title:  "Pt 1: Configuring Windows Server with Ansible - Updating Vagrant"
date:   2022-11-15 21:37:56
categories: [Vagrant]
tags: [Vagrant]
---

The post focuses on the recent experience that I've had updating Vagrant on both Arch and Void Linux in preparation for starting to work with Ansible to create a playbook to automate the creation of a Windows Server 2019 virtual machine as a domain controller.

It had been a few months since I had last worked with Vagrant and I was running Vagrant 2.1.9 on both devices, Vagrant 2.3.2 being the latest version of the application. Updating Vagrant is a straight forward process downloading the binary and then extracting and moving it to the /usr/bin/ directory and then executing vagrant --version to confirm the new version has been detected. This did return the expected version information checking to confirm the names of the Vagrant plugins that I have installed however returned an error. At a minimum the vagrant-libvirt plugin must be installed as this is the virtualisation management platform that I use.

```powershell
[craig][~]-> vagrant --version
Vagrant 2.3.2
[craig][~]-> vagrant plugin list
Vagrant failed to initialize at a very early stage:

The plugins failed to initialize correctly. This may be due to manual
modifications made within the Vagrant home directory. Vagrant can
attempt to automatically correct this issue by running:

  vagrant plugin repair

If Vagrant was recently updated, this error may be due to incompatible
versions of dependencies. To fix this problem please remove and re-install
all plugins. Vagrant can attempt to do this automatically by running:

  vagrant plugin expunge --reinstall

Or you may want to try updating the installed plugins to their latest
versions:

  vagrant plugin update

Error message given during initialization: Unable to resolve dependency: user requested 'pkg-config (= 1.4.7)'
```

Based on the above recommendations I tried all options starting with update, then repair and finally expunge. All failed to successfully resolve the issue with various Ruby gem dependencies being flagged as being unable to be resolved upon application launch. This sent me off down quite a rabbit hole trying to get the various dependencies that were missing installed. I did learn some useful ruby gem commands to manage the installation and removal of specific gem versions these commands all required me to use sudo to execute which on later reflection should of been an indicator that I was working to resolve the errors that Vagrant was reporting in a location that Vagrant didn't use /usr/bin/ruby. Vagrant stores its gems separately in the /home/user/.vagrant/ directory which as it is owned by my user sudo would not be required.

Digging around in the .vagrant.d directory I noted that there were two sub folders in the .vagrant.d/gems directory one named 3.0.3 and a second 2.7.5, both had similar contents and both had the vagrant-libvirt-0.7.0 gemfile which at that time was the dependency Vagrant was reporting could not be resolved. I decided it was best to clean up the .vagrant.d/ directory and let Vagrant recreate the working directory when I next executed a vagrant command.

```powershell
[craig][~]-> rm -rf .vagrant.d/
[craig][~]-> vagrant plugin install vagrant-mutate
Installing the 'vagrant-mutate' plugin. This can take a few minutes...
Fetching vagrant-mutate-1.2.0.gem
Installed the plugin 'vagrant-mutate (1.2.0)'!
[craig][~]-> vagrant plugin install vagrant-libvirt
Installing the 'vagrant-libvirt' plugin. This can take a few minutes...
Fetching xml-simple-1.1.9.gem
Fetching nokogiri-1.13.9-x86_64-linux.gem
Fetching ruby-libvirt-0.8.0.gem
Building native extensions. This could take a while...
Fetching formatador-1.1.0.gem
Fetching fog-core-2.3.0.gem
Fetching fog-xml-0.1.4.gem
Fetching fog-json-1.2.0.gem
Fetching fog-libvirt-0.9.0.gem
Fetching diffy-3.4.2.gem
Fetching vagrant-libvirt-0.10.8.gem
Installed the plugin 'vagrant-libvirt (0.10.8)'! 
```

## Conclusion
This experience has taught me that the next time I update Vagrant best practice will be to rename the current .vagrant.d directory and reinstall the plugins that I need and then copy the box files and other configuration files from the old directory across to the current directory. 

Below are some links to the documentation and other references I used when resolving this issue.

- Vagrant - [Download Vagrant](https://developer.hashicorp.com/vagrant/downloads)
- Vagrant Dependencies - [Ruby Version](https://github.com/hashicorp/vagrant/blob/main/vagrant.gemspec)
- stackoverflow - [Uninstall old versions of Ruby gems](https://stackoverflow.com/questions/5902488/uninstall-old-versions-of-ruby-gems)
