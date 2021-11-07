---
title:  "Sync OneDrive on Linux"
date:   2021-11-6 21:49:23
categories: [linux]
tags: [linux, OneDrive]
---


### Configure OneDrive Sync on Linux

I'm using the excellent OneDrive sync client from Abruanegg which is a command-line based client. The help documentation is very comprehensive for this program and this post captures specific options that are relevant to the setup and method I choose to manage what content is being synched to OneDrive.

### Run OneDrive as Systemd Service
The purpose of this is to ensure the OneDrive sync is enabled at boot and automatically synchronises any changes to files locally to the cloud.

To enable the OneDrive service enter the two below commands:
```vim
systemctl --user enable onedrive
systemctl --user start onedrive
```
The following command can then be executed to check the status of the OneDrive service which should now be active.
```console
systemctl status --user onedrive
* onedrive.service - OneDrive Free Client
     Loaded: loaded (/usr/lib/systemd/user/onedrive.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-10-10 16:25:00 AEDT; 5s ago
       Docs: https://github.com/abraunegg/onedrive
   Main PID: 29753 (onedrive)
      Tasks: 3 (limit: 4388)
     Memory: 5.5M
        CPU: 154ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/onedrive.service
             `-29753 /usr/bin/onedrive --monitor

Oct 10 16:25:00 archlinux systemd[320]: Started OneDrive Free Client.
Oct 10 16:25:00 archlinux onedrive[29753]: Configuration file successfully loaded
Oct 10 16:25:00 archlinux onedrive[29753]: Notification (dbus) server not available, disabling
Oct 10 16:25:00 archlinux onedrive[29753]: Configuring Global Azure AD Endpoints
Oct 10 16:25:02 archlinux onedrive[29753]: Initializing the Synchronization Engine ...
Oct 10 16:25:02 archlinux onedrive[29753]: Initializing monitor ...
Oct 10 16:25:02 archlinux onedrive[29753]: OneDrive monitor interval (seconds): 300
```

### Useful commands
Perform a one-way download sync
```vim
onedrive --synchronize --download-only
```
Perform a one-way upload sync
```vim
onedrive --synchronize --upload-only --no-remote-delete
```
Reset service when sync_list is modified
```vim
onedrive --synchronize --resync
```