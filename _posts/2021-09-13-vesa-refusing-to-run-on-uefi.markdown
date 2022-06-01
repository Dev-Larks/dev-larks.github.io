---
title:  "vesa: Refusing to Run on UEFI"
date:   2021-09-13 18:39:23
categories: [Linux]
tags: [Linux, Nvidia]
---

### Problem
I encountered this issue over the weekend just gone but didn't have the time to troubleshoot the error further until today this quick blog post is purely a reminder on what to check next time. I've been pretty busy the last month or two and used both my Linux systems minimally just powering on each week to apply all pending updates and in most cases not even trying to launch the window manager.

On Saturday morning I completed my usual update routine but then decided to try and launch my window manager by running startx only to be greeted by an error.  

vesa: Refusing to run on UEFI  
(EE) Fatal server error:  
(EE) no screens found  
(EE) Please consut the The X.Org Foundation support

I have both the latest and lts kernels on the machine and was able to successfully start an xsession with the 5.10 lts kernel using the startx command to launch my window manager. Today with some time to spare I setout to attempt to resolve this issue. Again I booted using the 5.14 kernel applied all updates and confirmed that the same error was still present. 

### Solution
Following the onscreen message I checked the log at /var/log/Xorg.0.log. After reviewing the various entries in the log file I could see that it was trying to use the Nvidia driver as expected but failing to find the relevant files/directory.

A quick check to confirm if the Nvidia driver was actually present on the system by running pacman -Qi returned no result. I'm not exactly sure how the nvidia driver was removed from the system, potentially an update has failed without me realising? 

After re-installing the latest version of the nvidia driver at the completion of this process there was a message in the terminal output stating that you must explicitly tell Xorg to use the Nvidia driver for kernel versions greater than or equal to 5.11.0. A quick check in the terminal confirmed that there was no configuration file present in that location.

Running the below command in the terminal and then rebooting the system restored the ability to run the startx command and launch a graphical user interface running kernel version 5.14.2

cp /usr/share/nvidia-340xx/20-nvidia.conf /etc/X11/xorg.conf.d
