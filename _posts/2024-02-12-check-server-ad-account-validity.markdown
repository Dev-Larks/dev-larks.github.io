---
title: "Check Computer Account Validity Across Two Domains"
date: 2024-02-12
categories: [PowerShell]
tags: [PowerShell]
---

My work environment is an organisation that has been merged together from several entities we have two primary AD environments. One of the primary focuses of my role is to manage/monitor server compliance against the monthly Microsoft patching cycle. I've developed several PowerShell tools to verify the status of servers that show as having an 'Unknown' status. These servers may have client issues preventing them from reporting their status or have been powered down either temporarily or for the purpose of being decommissioned.

One of the checks that I use to verify the state of unknown servers that are Inactive is to check if they are currently powered on via a simple Test-NetConnection test. This tool then creates two files with servers that respond and servers that don't. From the file of servers that don't respond to the ping test I then check if they have a computer record in either of the AD environments. I'd developed the below script that when I needed I opened from VS Code and executed from there. It prompted me for the name of a file which held the server names that I wanted to query and then went and checked their validity in AD.

```powershell
$content = Get-Item -Path C:\Data\Input\*  | Out-GridView -PassThru
$filePath = $content.DirectoryName
$file = $content.Name
$servers = Get-Content -Path $filePath\$file

foreach ($server in $servers) {
    Try {
        $domainA_ok = $true
        $status = (get-adcomputer -identity $server -ErrorAction Stop).Enabled
    }
    Catch {
        $domainA_ok = $false
        Write-Warning -Message "$server not found in domainA domain, checking if object exists in domainB AD"
        try {
            $domainB_ok = $true
            $status = (get-adcomputer -identity $server -server PRDDC1A.domainB -ErrorAction Stop).Enabled
        }
        catch {
            $domainB_ok = $false
            Write-Warning -Message "$server not found in domainA or domainB AD`n`n"
        }
        if ($domainB_ok){
            if ($status -eq $false) {
                Write-Information -MessageData "$server found in domainB AD" -InformationAction Continue
                write-Warning "$server account not enabled in domainB AD`n"
            }
            elseif ($status -eq $true) {
                Write-Information -MessageData "$server found in domainB AD" -InformationAction Continue
                Write-Information -MessageData "$server AD account is enabled`n" -InformationAction Continue
            }
        }
    }
    if ($domainA_ok) {
        if ($status -eq $false) {
            Write-Information -MessageData "$server found in domainA AD" -InformationAction Continue
            write-Warning "$server account not enabled in domainA AD`n"
        }
        elseif ($status -eq $true) {
            Write-Information -MessageData "$server found in domainA AD" -InformationAction Continue
            Write-Information -MessageData "$server AD account is enabled`n" -InformationAction Continue
        }
    }

}
```

The biggest challenge with the script in this format was that the logic did not support the scenario if a record was found in DomainA that was not enabled the script then moved to the next server in the list rather than checking if a record was present in DomainB. Wanting to break the script down into smaller functions that just managed one specific domain I refactored the code creating a controller script that calls three private functions. I also added the functionality to support just specifiying a server/s by name when calling the function or if using the File parameter to then be prompted for a file to consume this information from. As part of this refactoring process I also added the missing logic to support also checking for a record in DomainB if a computer record that was not enabled was found in DomainA.

```powershell
function Get-ServerADValidity {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline = $True,
            HelpMessage = "Name of the server to check")]
        [Alias('Server')]
        [string[]]$ServerName,

        [switch] $File
    )

    begin {

        $domainA = (((Get-ADDomain).name).toUpper())
        $domainB = (((Get-ADDomain -Server PRDDC1A.domainB).name).toUpper())

        if ($File) {

            $servername = Get-InputSourceFile
        }

    }

    process {

        foreach ($server in $servername) {

            $status = Confirm-domainAServerADValidity -Server $server

            if ($null -eq $status) {
                $status = Confirm-domainBServerADValidity -Server $server
                if ($null -eq $status) {
                    <# Action to perform if the condition is true #>
                } else {
                    "$server" + ": found in $domainB     Enabled: $status`n"
                }
            } elseif ($status -eq $false) {
                $status = Confirm-domainBServerADValidity -Server $server
                if ($null -eq $status) {
                    <# Action to perform if the condition is true #>
                } else {
                    "$server" + ": found in $domainB     Enabled: $status`n"
                }
            } else {
                "$server" + ": found in $domainA    Enabled: $status`n"
            }

        }

    }

    end {

    }
}
```

The two private functions that query AD are structured like this.

```powershell
function Confirm-domainAServerADValidity {
    param (
        $server
    )

    try {
        $domainA_ok = $true
        $status = (get-adcomputer -identity $server -ErrorAction Stop).Enabled
        if ($domainA_ok) {
            $status
        }
    }
    catch {
        $domainA_ok = $false
        Write-Warning -Message "$server object not found in domainA AD"
    }

}
```

The structure of the private function to prompt for a file if specified.

```powershell
function Get-InputSourceFile {
    param (

    )

    $content = Get-ChildItem -Path C:\Data\Input\* | Out-GridView -PassThru
    $filePath = $content.DirectoryName
    $sourcefile = $content.Name
    $servername = Get-Content -Path $filePath\$sourcefile
    $servername

}
```
### Conclusion

I intend to create a new module for these functions to allow for them to be loaded when I open Windows Terminal and available to use when needed. The new systems operations role that I've moved into has provided a lot of scope for using PowerShell in my day to day work to make tasks such as validating server state a quick and simple process.

*Thanks for Reading,* 
*Craig*

### Sources

- How to handle null differently from false [stackoverflow](https://stackoverflow.com/questions/46223726/powershell-booleans-how-to-handle-null-differently-from-false)
