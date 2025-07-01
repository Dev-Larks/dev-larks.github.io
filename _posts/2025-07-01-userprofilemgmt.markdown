---
layout: post
title: "Checking User Profile Last Logon Timestamps"
date: 2025-07-01
readtime: true
tags: [powershell]
---

<!--more-->
As part of monthly patch management activities I routinely have to address low disk space issues on servers so that patches can be successfully installed. For some servers the main culprit for excessive diskspace usage is easy to see and I have implemented scripts in the past to manage large/old log files that are problematic. This month I had a server that had 30GB of user profiles, and two 20GB Program Files directories, which contained Visual Studio, Microsoft SDKs, DotNet, and ArcGis applications. It had very limited options to recover disk space but had over 35 user profiles present, I usually check the last time a user profile was used individually by using this command "net user USERID /domain| findstr "Last"". This obviously doesn't scale well and is cumbersome to check each individual account.

Initially I put together the following script which outputs the information I need but not as cleanly as I would like. I wanted the output in a table format with the username on the left and the last logon timestamp neatly aligned on the right.

```powershell
Get-Item -Path C:\users\*  -Exclude "Public" | select -ExpandProperty Name | Out-File C:\Temp\UserAccounts.txt
$a = Get-Content "C:\Temp\UserAccounts.txt"
foreach ($user in $a) {
    $ll = net user $user /domain | findstr "Last"
    Write-Output $user`t$($ll.Substring(10))
    }
admin-userl	                   25/06/2025 11:58:33 AM
admin-user2	                   26/06/2025 12:37:08 PM
larkinc	               26/06/2025 12:37:53 PM
```

In an attempt to tidy up the format of what the script was outputting I refactored and put both the user and last logon objects into a hashtable. This did result in output that at a column level looked more visually pleasing however the columns had a Name and Value heading which I didn't like and the order of the objects was randomly determined by PowerShell. Specifying that the hashtable should be ordered resolved the second issue but the Name, Value headings remained to be removed and the output wasn't really in the easy to read format what I'd set out to achieve.

```powershell
Get-Item -Path C:\users\*  -Exclude "Public" | select -ExpandProperty Name | Out-File C:\Temp\UserAccounts.txt
$a = Get-Content "C:\Temp\UserAccounts.txt"
foreach ($user in $a) {
    $lastlogon = (net user $user /domain | findstr "Last").Substring(10)
	$props = [ordered]@{'UserName' = $user;
	                    'LastLogon' = $lastlogon
	}
    #Write-Output $user`t$($ll.Substring(10))
    $props
    }

Name                           Value
----                           -----
UserName                       admin-user1
LastLogon                      25/06/2025 11:58:33 AM
UserName                       admin-user2
LastLogon                      26/06/2025 12:37:08 PM
UserName                       larkinc
LastLogon                      26/06/2025 12:37:53 PM
```

The first option that I tried from a Reddit thread was using the GetEnumerator() method on the $props object, this did remove the Name and Value headings but put two carriage returns between each of the users that was output. For a server with multiple user profiles I felt this could be problematic due to the real estate the output would consume.

```powershell
UserName                       admin-user1
LastLogon                      16/06/2025 11:44:30 AM


UserName                       admin-user2
LastLogon                      29/06/2025 7:30:00 AM


UserName                       larkinc
LastLogon                      27/06/2025 1:01:01 PM
```

I tried another option to which was to place all output into a string and then split it at each line break, trim any carriage returns, remove the blank lines and then skip the Name and Value heading. This resulted in the below output which was definitely an improvement on what I'd managed to this point.

```powershell
$props = ($props |
    Out-String).Split("`n").Trim() |
    Where-Object {$_} |
    Select-Object -Skip 2

    $props
}
UserName                       admin-user1
LastLogon                      16/06/2025 11:44:30 AM
UserName                       admin-user2
LastLogon                      29/06/2025 7:30:00 AM
UserName                       larkinc
LastLogon                      27/06/2025 1:01:01 PM
```

However it wasn't in the column format that I really wanted, it was while writing this post that I found the solution. Historically I would usually pipe the output of the hashtable that I created to a PSObject I had not done this while working on this script. A quick test resulted in the easy to read output that I was after. I also discovered that the $lasglogon.Substring value from 10 to 29 to remove all the white space before the timestamp that net user returns. The final version of this script is below.

```powershell
Get-Item -Path C:\users\*  -Exclude "Public", "Default", "Administrator", "svc*", "*.NET*" | select -ExpandProperty Name | Out-File C:\Temp\UserAccounts.txt
$accounts = Get-Content "C:\Temp\UserAccounts.txt"
foreach ($user in $accounts) {
    $lastlogon = (net user $user /domain | findstr "Last").Substring(29)

    $props = [ordered]@{'UserName' = $user;
	                    'LastLogon' = $lastlogon
	}

    $obj = New-Object -TypeName psobject -Property $props
    Write-Output $obj

}

UserName        LastLogon
--------        ---------
admin-user1 	16/06/2025 11:44:30 AM
admin-user2   	29/06/2025 7:30:00 AM
larkinc         27/06/2025 1:01:01 PM
```

I'm very happy with this and the resolution to the display output that I wanted was simple to implement. It has proven to be a useful tool to leverage in my activities related to disk space management across our server fleet and provides an efficient way to find stale user profiles.




*Thanks for Reading,*  
*Craig*

### Sources
Below are the sources that I referenced when developing this tool.
- Lee_Dailey - Remove Headers from Hashtable Output [Reddit](https:/reddit.com/r/PowerShell/comments/8epoxt/remove_headers_from_hashtable_output)
- mjv - Difference between CR LF, LF and CR line break types [stackoverflow](https://stackoverflow.com/questions/1552749/difference-between-cr-lf-lf-and-cr-line-break-types)
