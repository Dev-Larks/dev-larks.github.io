---
title:  "Get Proxy Details from Remote Machine"
date:   2022-05-31 17:56:31
categories: [PowerShell]
tags: [PowerShell]
---

The environment that I work in is complex with several different ICT environments in the process of being brought together. Working in second level support one of the common things that I like to capture is a baseline of the current device configuration, which includes the Windows version, VPN configuration, and the proxy that has been configured for the user. The environment has PSRemoting configured which allows for devices that are in a corporate office to be queried for configuration information. I'm yet to test to see if devices connected by VPN can also be queried in this same manner.

I had been speaking with a customer in a remote location and later while reviewing the ticket notes realised I hadn't verified the proxy configuration of the machine which had been powered off for the day. From prior testing I already knew that I could query the registry to get the configured proxy URL using the Get-ItemProperty cmdlet on my machine. 

```powershell
Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
```
The process to query for this information on a remote machine I quickly discovered required a different approach. I found I could only query the details of the currently logged in user which in this scenario was not helpful as this was not the same person I had been talking with the previous day. I knew that I could get a list of user profiles from the HKEY_LOCAL_MACHINE registry hive, but it took some trial and error and further research to realise that I needed to query the HKEY_USERS hive to access settings for other user profiles. What follows is an overview of the logical process I used to retrieve this information.

As part of the troubleshooting completed the previous day I'd discovered that the 'Remote Registry' service is off by default. I used a PS Session to connect to the machine and by trial and error determined the cmdlets and the structure that I needed to retrieve the proxy configuration for a user when they are not the currently logged in on a device. What follows is an overview of the logical process I used to retrieve this information.

```powershell
Get-Service RemoteRegistry
```

This confirms that the service is not running and needs to be started with the following cmdlet.

```powershell
Start-Service RemoteRegistry
```

The next part of the puzzle was how to get the list of Security Identifiers (SIDs) for the users who had logged in on the device from the registry, the Get-ItemProperty cmdlet again provided this information. To reduce the amount of information retrieved I selected just the two properties that would allow me to determine who each SID belonged to.

```powershell
Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | select ProfileImagePath, PSPath
```

The Read-Host cmdlet is then used to prompt the user to paste the SID for the user from the output of the previous cmdlet, saving the user input to the $SID variable.

```powershell
$SID = Read-Host -Prompt 'Paste the SID for the user here:'
```

With the SID for the user I wanted now known I was able to then query the user data held in the HKEY_USERS registry hive or so I thought.

```powershell
Get-ItemProperty -Path "Registry::HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
```
While this did return information about the user it did not include the proxy configuration, I amended the query slightly by placing the output of the query into a variable and then specifying the property to return.

```powershell
$proxy = Get-ItemProperty -Path "Registry::HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$proxy.AutoConfigURL;
```

With a working solution that took 6 individual steps to complete I then looked for other ways that I could achieve this same outcome by just using one command. I considered turning this into a script or a function but then started looking at the Invoke-Command cmdlet. I discovered that you could string a list of commands together to execute one after another. This was the approach that I took however, I do intend to ultimately create a standalone script that I can call using the Invoke-Command cmdlet and include the code from this post into a broader function that will retrieve the all the baseline configuration information for a device as outlined in the introduction to this post.

I did start some further refinement of this approach initially considering querying AD directly to get the users SID, but this approach has limitations where there are multiple users with the same name. I thought that using Out-Gridview would provide an option to manage this scenario but this functionality is not available in when using Invoke-Command against a remote machine. Ultimately for the time being I've retained the Read-Host function to specify the users SID, the final version of this set of commands is below.

```powershell
Invoke-Command -ComputerName "Serial#Here" {get-service RemoteRegistry; start-service RemoteRegistry; Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | select ProfileImagePath, PSPath; $SID = Read-Host -Prompt 'Paste the SID for the user here:'; $proxy = Get-ItemProperty -Path "Registry::HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Internet Settings"; $proxy.AutoConfigURL; Stop-Service RemoteRegistry}
```

#### Conclusion

I really enjoyed the process of discovery as I worked through the steps to successfully retrieve the information that I was looking for. I was amazed at the flexibility that the Invoke-Command cmdlet provides. I'm hoping that this solution can be put into use for users who are working remotely also but this still remains to be tested. Below are links to the documentation and blog posts that I used to work create my solution.

#### Sources
Below are links to the key resources that I referenced when working through the process to refactor this function.

- Janvi - Powershell: Get registry value data from remote computer [Blogpost](http://vcloud-lab.com/entries/powershell/powershell-get-registry-value-data)
- Nick Venenga - Powershell check if on metered network [Github gist](https://gist.github.com/nijave/d657fb4cdb518286942f6c2dd933b472)
- Microsoft Docs - PowerShell Invoke-Command [Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command?view=powershell-7.2)
- Diwas Poudel - Run multiple commands in one line in Powershell and Cmd [Blogpost](https://ourtechroom.com/tech/run-multiple-commands-one-line-powershell-cmd/)
- Microsoft Docs - Working with Registry Entries - PowerShell [Documentation](https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries?view=powershell-7.2)
