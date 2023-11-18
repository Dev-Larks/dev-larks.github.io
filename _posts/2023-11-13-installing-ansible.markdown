---
title:  "Pt 2: Configuring Windows Server with Ansible - Preparing Vagrant and Installing Ansible"
date:   2023-11-13 21:37:56
categories: [Vagrant, Ansible]
tags: [Vagrant, Ansible]
---

In preparation for the installation of Ansible, I invested some time to go back through the Vagrant documentation to refamiliarise myself with the Vagrant CLI commands and vagrantfile syntax. I enabled Vagrant command  autocompletion in bash by running the below command.
```powershell
vagrant autocomplete install --bash
```

I then also created directories and symbolic links to move the boxes that are downloaded and images that are created when using Vagrant to a separate partition to that which Void is installed on.
```powershell
sudo mkdir -p libvirt/{images,isos}
sudo ln -s /files/libvirt/isos ~/vagrant.d/boxes
sudo ln -s /files/libvirt/images /var/lib/libvirt/images
```

Given that the purpose of this excercise is to create a test environment that I can validate the functionality of my PowerShell scripts I created a lab directory and then changed to that directory in the terminal and entered 'vagrant init' to create a basic Vagrantfile. I decided to use the Windows Server 2019 box that was created by jborean93 and available from Vagrant Cloud. My initial Vagrantfile was very basic.

```powershell
Vagrant.configure("2") do |config|
  config.vm.box = "jborean93/WindowsServer2019"
end
```
I ran the 'vagrant up' command to begin the download of the box from Vagrant Cloud. Once the box was downloaded Vagrant completed the boot process and I was able to successfully connect using vagrant-ssh.

Installing Ansible
I initially wanted to install Ansible using pip, but this would of required using Python in a virtual environment wanting to avoid the additional learning overhead I settled on using the Ansible package from the official Void repos.
The install took a couple of minutes to complete, checking the version of Ansible installed by running ansible --version returned the below information
`

```powershell
[craig][~/dev/Ansible]-> ansible --version
ansible [core 2.15.0]
  config file = None
  configured module search path = ['/home/craig/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.12/site-packages/ansible
  ansible collection location = /home/craig/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.0 (main, Oct  6 2023, 16:16:58) [GCC 12.2.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
  ```

Keen to try a simple ping test to confirm I could communicate to my VM using Ansible I created a hosts.ini file and ran the following command: ansible -i hosts.ini lab -m ping -u vagrant --ask-pass
```powershell
[craig][~/dev/Ansible/Windows_Lab]-> ansible -i hosts.ini lab -m ping -u vagrant --ask-pass
SSH password:
192.168.121.119 | FAILED! => {
    "msg": "to use the 'ssh' connection type with passwords or pkcs11_provider, you must install the sshpass program"
}
```

Installing the sshpass program did not immediately provide the successful connection that I was looking for. Some further reading of the Ansible documentation and some experimentation provided the ability to successfully connect using Ansible and ping my lab server. I had to change the module (-m) that I was requesting to use to win_ping, and add an extra parameter -e 'ansible_shell_type=cmd'. The amended command looks like this:
```powershell
[craig][~/dev/Ansible/Windows_Lab]-> ansible -i hosts.ini lab -m win_ping -e 'ansible_shell_type=cmd' -u vagrant --ask-pass
SSH password:
192.168.121.119 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

 
## Conclusion
It has been almost a year since I'd last looked at this project and it took some time to refamiliarise myself with the syntax for Vagrant and Ansible. Having moved into a SysOps role in recent months and having greater opportunity to use PowerShell in everyday work tasks I'm keen to continue to invest time to learn these two technologies. To this end I intend to work through the two resources that I have from Josh Duffney - Become Ansible and Jeff Geerling - Ansible for DevOps and apply what I learn to automate the setup of my lab environment.

Below are some links to the documentation and other references I used when resolving this issue.

- Windows Server Box [jborean93](https://app.vagrantup.com/jborean93/boxes/WindowsServer2019)
- Windows SSH Setup [Ansible Docs](https://docs.ansible.com/ansible/latest/os_guide/windows_setup.html#windows-ssh-setup)
