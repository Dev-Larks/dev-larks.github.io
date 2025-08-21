---
layout: post
title: "Parsing Text to Retrieve Server Names"
date: 2025-08-21
readtime: true
tags: [powershell]
---

<!--more-->
Each month I monitor the Windows Update compliance across the various maintenance windows that we have established. Often there are groups of servers that fail to install updates when the maintenance window opens. The following day I review compliance in the Configuration Manager console and connect to the servers with a status of 'In Progress' by RDP. Initially I used to just scroll down the list of servers and type in their names manually to the RDP connection window. I then moved to copying out the list of servers from the Configuration Manager console and manually formatting the info into just the list of server names which I'd then individually cut and paste into an RDP connection. The raw format of the information copied out of Configuration Manager is below.

16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),DVVSRV4001,Non-compliant,17/08/2025 12:17 AM,,,,Downloaded update(s),17/08/2025 12:19 AM,16807016,Downloaded update(s),0X00000000,Success,17/08/2025 12:19 AM,(SYSTEM),Yes,No,Yes,
16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),DVVSRV4213,Non-compliant,17/08/2025 2:36 AM,,,,Downloaded update(s),17/08/2025 2:37 AM,16799353,Downloaded update(s),0X00000000,Success,17/08/2025 2:37 AM,(SYSTEM),Yes,No,Yes,
16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),DVVSRV4021,Non-compliant,17/08/2025 12:31 AM,,,,Downloaded update(s),17/08/2025 12:31 AM,16795516,Downloaded update(s),0X00000000,Success,17/08/2025 12:31 AM,(SYSTEM),Yes,No,Yes,
16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),SRVWB46,Non-compliant,16/08/2025 11:37 PM,,,,Downloaded update(s),16/08/2025 11:38 PM,16791482,Downloaded update(s),0X00000000,Success,16/08/2025 11:38 PM,(SYSTEM),Yes,No,Yes,
16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),SRVWB47,Non-compliant,16/08/2025 11:19 PM,,,,Downloaded update(s),16/08/2025 11:19 PM,16787207,Downloaded update(s),0X00000000,Success,16/08/2025 11:19 PM,(SYSTEM),Yes,No,Yes,
16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),JSRV4001,Non-compliant,17/08/2025 1:59 AM,,,,Downloaded update(s),17/08/2025 2:01 AM,16813595,Downloaded update(s),0X00000000,Success,17/08/2025 2:01 AM,(SYSTEM),Yes,No,Yes,
16785150,Software Updates - Windows Servers_4_2025-08-16 22:10:09,Maintenance Window - Software Updates - Servers - Phase 2.1 Monday (DEV/UAT),SRVAD4001,Non-compliant,17/08/2025 3:19 AM,,,,Downloaded update(s),17/08/2025 3:20 AM,16795517,Downloaded update(s),0X00000000,Success,17/08/2025 3:20 AM,(SYSTEM),Yes,No,Yes,

This month I decided to try and extract the list of server names from that raw output using PowerShell, initially I took the raw output and put it into a variable to capture the length which was 2235 characters. I then calculated the number of characters to the first server name which was 143 characters.

```powershell
$startLength = $a.Length
$newLength = $startLength - 143
$a = $a.SubString(143,$newLength)
```
I then calculated the length of the characters to the next server name which was 312, but at this point I realised that the maintenance window and server names are not all the same length so a hard coded value to continue to use the substring approach was not viable nor was I sure how I would implement this approach.
I then looked at splitting the string at every comma to change it into an array as this would provide a consistent position regardless of the length of the information between the commas. I then looked at the values in the $b variable and calculated that the gap between each server name was 20.

```powershell
$b = $a.Split(',')
$b.Length
81
$b.Count
81
$b.[3]
DVVSRV4001
$b[23]
DVVSRV4213
```
At this point I knew the spacing between server names but was uncertain how to proceed to loop through the array after the first server name get every twentieth entry. I tried a few different approaches but the logic I attempted to implement was always flawed and either errored or didn't produce the output I expected. I completed some research to see how others had managed similar PowerShell use cases. I came across a Reddit thread which with some slight modification of the values provided a simple solution to the problem.

```powershell
function Get-DPE_MECMInProgressServerNames {
    [CmdletBinding()]
    param (
        [string] $Content
    )

    begin {

    }

    process {
        $delimiter = ","
        $splitArray = $Content -split $delimiter

        for ($i = 3; $i -lt $splitArray.Length; $i += 20) {
            $Output += $splitArray[$i] | Out-String
        }

        $Output | Set-Clipboard

    }

    end {

    }
}

```

Outputs server names

DVVSRV4001  
DVVSRV4213  
DVVSRV4021  
SRVWB46  
SRVWB47  
JVSRV4001  
SRVAD4001  


I am really happy with the simplicity of this function which meets all the requirements of my use case. It will make it much quicker to get the list of servers that I need rather than either manually typing in each server name or manually formatting the initial output from the console to remove the unneeded text as at times I can have up to 30+ servers to check.





*Thanks for Reading,*
*Craig*

### Sources
Below are the sources that I referenced when developing this tool.
