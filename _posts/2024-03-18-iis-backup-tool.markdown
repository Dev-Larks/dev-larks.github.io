---
layout: post
title: "IIS Application/Website Backup Tool"
date: 2024-03-18
categories: [PowerShell]
tags: [PowerShell]
---

One of the key tasks in my current role is assisting the developers to deploy their application/website code changes from UAT to Production. A standard part of this process is to backup the existing application/website directory in case the change is unsuccessful. I came across a folder on one of the servers which had 50+ PowerShell scripts that had been developed to backup individual applications, I used one of these as the template for the tool that I created.

Original Backup Script

```powershell
$source = "D:\inetpub\wwwBOPAPP"
$archiveStampDate = "_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$destination = "D:\software\_predeploymentbackup\" + "wwwBOPAPP_PRD_" + $archiveStampDate + "_.zip"
If(Test-path $destination) {Remove-item $destination}
$CompressionToUse = [System.IO.Compression.CompressionLevel]::Optimal
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($Source, $destination)
Write-Output "Backup completed for wwwBOPAPP on webserver46"
Write-Output "------------------------------------------------"
```

There were elements of this script that I felt were not relevant given the current backup naming conventions that are being used. I added a variable to capture the change or incident ticket number using Read-Host, removed the time component of the archive timestamp and changed the destination path and format. These changes provided the backup functionality that I needed and removed the need to complete this task manually.

Interim Backup Script
```powershell
#Backup BOPBCT
$source = "D:\Inetpub\wwwBOPAPP"
$INC = Read-Host -Prompt "Enter the INC or CHG number in full"
$archiveStampDate = "_" + (Get-Date).ToString("yyyy-MM-dd")
$destination = "D:\Backup\$INC" + "_wwwbopapp_$archiveStampDate.zip"
If(Test-path $destination) {Remove-item $destination}
$CompressionToUse = [System.IO.Compression.CompressionLevel]::Optimal
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($Source, $destination)
Write-Output "Backup of wwwBOPAPP completed on webserver46"
Write-Output "------------------------------------------------"
```

The key limitation with that version of the tool was that individual backup scripts would still need to be created to manage the other applications/websites that were hosted on the server. This led me to thinking how I might create a single universal tool that could be used to complete this process. A key element of this approach would be providing a GUI Folder select dialog window to support the capability to browse and select the folder and contents to backup. I started to do some research and found various scripts that I didn't fully understand before coming across a very simple implementation of what I wanted from a blog post by Jaap Brasser.
```powershell
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$FolderBrowser.ShowDialog()
$FolderBrowser.SelectedPath
```

This provided the capability to specify the default path to open the dialog window in and also the option to remove the create new folder button. The next part of the puzzle was to come up with a way to dynamically provide a value for the application name. Similar to the earlier iterations of this tool the $source variable would hold the source path to the application/site to be backed up. I confirmed that the $source was a string object and then used the Split method to break the directory path in the $source variable by the \ character. This achieved exactly what I wanted but I was unsure how to always get the last part of the $source variable path so I could use this as the application name in the $destination variable. This turned out to be remarkably easy as regardless of how long the path was the ```powershell $source.Split ('\')[-1]``` method will always return the last element of the directory path.

The first time I used this tool I discovered a key limitation, in particular if a sub-folder of an application/website was all that was required to be backed up. In its current guise the name of the application/website in the destination path would be meaningless and without context of the application/site it was associated with. I solved this problem by turning the script into a function and adding an optional switch parameter called IncludeParent which would then include the primary application/site name as well as the child directory that was being backed up.

Current Version
```powershell
function Backup-IISApp {
    [CmdletBinding()]
    param (
        [switch] $includeParent
    )

  begin {

        #Backup IIS APP select app directory
        Add-Type -AssemblyName System.Windows.Forms
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
            SelectedPath        = 'D:\Inetpub\’
            ShowNewFolderButton = $false
        }
        [void]$FolderBrowser.ShowDialog()
        $source = $FolderBrowser.SelectedPath

        $archiveStampDate = (Get-Date).ToString("yyyy-MM-dd")

        $INC = Read-Host -Prompt "Enter the INC or CHG number in full"

        #Get the last folder name from the source directory path
        $app = $source.Split('\')[-1]
        $app2 = $source.Split('\')[-2]

        if ($includeParent) {
            $app = "$app2" + "_$app"
        }
        else {
            $app
        }

        $destination = "D:\Backup\$INC" + "_$app" + "_$archiveStampDate.zip"

     }

     process {

        Write-Output "`n------------------------------------------------"
        Write-Output "Backup of $app directory initiated on $Env:COMPUTERNAME`n"
        #Create backup .zip file in D:\Backup directory
        If (Test-path $destination) { Remove-item $destination }
        Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($Source, $destination)
        Write-Output "Backup of $app completed on $Env:COMPUTERNAME"
        Write-Output "------------------------------------------------`n"

    }

    end {

    }
}
```
After some testing I removed the $CompressionToUse variable which was declared but never used as the size of the .zip file that was created was the same regardless of whether this value was specified or not. I also added some additional text decoration that is written to the console when executing the function and also moved to using the $Env:COMPUTERNAME environment variable so that the server name is not hard coded. The function is currently dot-sourced to my PowerShell profile to make using the tool a simple and straightforward task.

*Thanks for Reading,*
*Craig*

### Sources

- Folder browser dialog class [PowerShell Magazine](https://powershellmagazine.com/2013/06/28/pstip-using-the-system-windows-forms-folderbrowserdialog-class/)
- About Split [Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_split?view=powershell-7.4)

