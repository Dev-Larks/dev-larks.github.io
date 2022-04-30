---
title:  "Refactoring a PowerShell Function"
date:   2022-04-29 11:16:42
categories: [PowerShell]
tags: [PowerShell]
---

My place of work uses the Microsoft Always on VPN solution, the configuration for end users and devices is managed through the membership of Active Directory (AD) groups and the requirement that the device is in a specific OU. I initially developed a PowerShell tool that checked for the presence of a nominated user and their device in these groups. This tool was flexible through the use of a 'Switch' construct and could be used to only verify if the required AD groups were present or proactively remediate any missing groups. The initial version of this tool was broken into three logical sections verifying the presence of the required user groups and then moving to verify the device groups before checking the OU the device was in. A series of repeated 'if' statements structured as shown below was used to verify the presence of each of the VPN AD groups and remediate if not specified to query only.
```powershell
if ($false -eq $userVpn.Contains('G-SE-CORP-User-Cert')) {
    if ($noRemediate) {
        Write-Warning "G-SE-CORP-User-Cert AD group missing"
                }
    else {
        Write-Verbose "G-SE-CORP-User-Cert AD group missing adding group"
        Add-ADGroupMember -Identity 'G-SE-CORP-User-Cert' -Members $userId -Credential (Get-Credential)
        }                     
}
else {
Write-Host "G-SE-CORP-User-Cert AD group present" -ForegroundColor Green
}
```
In total this PowerShell function was 162 lines in length. I was keen to reduce the amount of code and also simplify and optimise the process that was used by using a loop construct. While I was studying at university I could remember fellow students in one of my cohorts stating the use of multiple 'if' statements did slow program execution as they were slower to iterate through.

To start the refactoring of this tool, I placed the names of the required AD groups into two variables $vpnUserGroups and $vpnDeviceGroups. I then queried the users AD group membership and selected just the AD group name and placed these into a $userVpn variable. I used the .GetType() method to confirm what the contents of the $vpnUserGroups variable which confirmed that it was indeed an array of objects.
```powershell
$vpnUserGroups.GetType()

Is Public   IsSerial    Name                     BaseType
---------   --------    ----                     --------
True        True        Object[]                 System.Array
```
With this confirmed I then created a foreach loop where the presence of each of the required VPN AD groups were verified to be present in the $userVPN variable. Again the option to remediate missing groups was managed through a 'Switch' construct.
```powershell
foreach ($group in $vpnUserGroups) {
            
    if ($everything_ok) {
        if ($userVPN -Contains $group) {
            Write-Host "$group AD group present" ForegroundColor Green
        }
        else {
            if ($noRemediate) {
                Write-Warning "$group AD group missing"
            }
            else {
                Write-Verbose "$group AD group missing adding group"
                Add-ADGroupMember -Identity '$item' -Members $userName -Credential (Get-Credential)
            }
        }
    }
}
```

I used the same logic in a foreach loop to query and verify that the required device AD groups were also present in the $vpnDeviceGroups variable.
#### Conclusion
This refactoring exercise reduced the number of lines of code in the function by 56. After running the Measure-Command 10x against the original and refactored functions the time taken to execute the queries  averaged out to show that the method of looping over and checking for the presence of the AD groups is actually slightly slower by .12 of a second which was a surprise. I would like to test this again when in the office and directly connected to the corporate network to see if the result is the same.
```powershell
for ($i=1; $i -le 10; $i++) { Measure-Command { Get-DPE_VPNTestState -userName 'Craig Larkin' -computerName PC0V3MBM } }
```
Overall I found this exercise to be very beneficial to my understanding of how different constructs such as loops or if statements can be applied to solve problems using PowerShell. The use of the .GetType() method to verify that the variables that held the user and device VPN groups were both arrays was the catalyst that started the process to move to using a loop rather than multiple if statements. Despite the fact that in its refactored form the tool completes the verification process slightly slower the time invested and the learning process were still worthwhile.

#### Sources
Below are links to the key resources that I referenced when working through the process to refactor this function.

- Tommy Maynard - There is a Difference: Arrays Versus Hash Tables [Blogpost](https://tommymaynard.com/there-is-a-difference-arrays-versus-hash-tables/?msclkid=4a6e2573c5d411ec917b3e734980cb51)
