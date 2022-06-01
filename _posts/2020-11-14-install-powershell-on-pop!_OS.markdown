---
title:  "Installing PowerShell 7.1 on Pop!_OS"
date:   2020-11-14
categories: [Linux, PowerShell, Pop!_OS]
tags: [Linux, PowerShell, Pop!_OS]
---
I've installed Pop!_OS 20.04 LTS on an old Apple Mac Mini 3.1. Pop!_OS is based on Ubuntu and version 20.04 has just been officially supported by the just released PowerShell 7.1.

As per the Microsoft documentation I performed the below steps to complete the install via a Package Repository:

sudo apt-get update

![sudo apt-get update](/images/Install pwsh71_000.png)

sudo apt-get install -y wget apt-transport-https, I already had the latest version so there was no install or upgrade required for the pre-requisite packages.

![Install wget](/images/Install pwsh71_001.png)

The following commands download and register the Microsoft GNU Privacy Guard (GPG) keys for the Microsoft repository that contains the PowerShell 7.1 source files.

wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb

sudo dpkg -i packages-microsoft-prod.deb

![Add PS7 repository](/images/Install pwsh71_003.png)

sudo apt-get update, was run again followed by sudo add-apt-repository universe which was confirmed as already being enabled.

![PS7 repository present](/images/Install pwsh71_004.png)

The actual install was then inititated sudo apt-get install -y powershell
It completed but with two unmet dependencies, after some research to understand what these dependencies were I decided to try the other install option. This was due to the fact that one of the dependencies was no longer available in the Official Ubuntu repositories after Ubuntu 18.04 and sourcing this directly from the Debian repositories was not considered to be good practice.

![PS7 missing dependencies](/images/Install pwsh71_005.png)

To get my system with a working version of PowerShell 7.1 I downloaded the Debian package powershell_7.1.0-1.ubuntu.20.04_amd64.deb from the PowerShell 7.1 GitHub releases page.

Then, in the terminal, the following commands were executed:

sudo dpkg -i powershell_7.1.0-1.ubuntu.20.04_amd64.deb
This completed with the below errors, the presence of errors at this point is mentioned in the install documentation.

![PowerShell 7.1 debian package errors](/images/Install pwsh71_006.png)

These errors were resolved by running: sudo apt-get install -f

![PowerShell 7.1 error resolution](/images/Install pwsh71_007.png)

Typing pwsh starts PowerShell in the terminal and entering $psversiontable confirmed PowerShell 7.1 is installed.

![$PSVersionTable details](/images/Install pwsh71_009.png)

The process to install PowerShell 7.1 was ultimately very straight forward, however the installing directly from the source downloaded from GitHub was the method required to successfully complete the installation of PowerShell 7.1.

Link to Microsoft documentation: Installing PowerShell on [Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004){:target="_blank"}
