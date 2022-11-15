---
title:  "Compare Device Active Directory Group Membership"
date:   2022-06-21 16:47:56
categories: [PowerShell]
tags: [PowerShell]
---

I often swap out user devices due to either hardware issues or other Windows problems that are quicker to resolve following this process for the user. One of the key element of this process is to ensure that the necessary groups from the users old device are copied across to the new device as most line of business applications are deployed by Microsoft Endpoint Configuration Manager via Active Directory (AD) groups. 

Knowing that using PowerShell would provide a quicker process and arguably easier option than searching via the GUI and opening and then comparing the two devices I decided to create a tool to provide this information. I wanted the tool by default to only query and write the results out to the console, but also provide an option for the tool user to select AD groups from the old device to be added to the new device through the use of a switch statement. When using the switch option the results of the comparison would be written to both the console and also to a GUI interface using the Out-Gridview cmdlet.

The process to capture each of the devices group memberships was accomplished using the Get-ADPrincipalGroupMembership cmdlet and storing the result in a variable. Following best practice I implemented error handling in case either the source or new device asset names were entered incorrectly.

```powershell
try {
    $everything_ok = $True
    $sourceDeviceMembership = Get-ADPrincipalGroupMembership `
    $sourceComputer$ -ErrorAction Stop | Select-Object name
    } catch {
        Write-Warning "$sourceComputer not found in $domain `
	check spelling and try again"
    }
```

With both device AD groups captured in variables the Compare-Object cmdlet then compares the contents of both device AD group membership variables and writes the group information to the console. Groups common to both devices are represented with an '=' symbol. Groups that are not common use the following symbols '<=' for AD groups unique to the source device and '=>' representing AD groups unique to the new device.

```powershell
$groups = Compare-Object ($sourceDeviceMembership) ($newDeviceMembership) -Property Name -IncludeEqual
```

It was at this point where I encountered an issue with writing the contents of the $groups variable out to the console, if the function was executed without the -addGroups switch the comparison of the two devices was written to the terminal as expected. If however I used the -addGroups switch the Out-Gridview graphical window would display but no data would be written to the console. The data from the initial query would only be written to the console after I had interacted with the Out-Gridview window which was not what I wanted. I tried using both the Write-Host and Write-Output cmdlets rather than just having the variable value written directly to the console but neither of these resolved this issue. 

I resolved this problem after finding a thread on Stack Overflow by piping the output of the $groups variable to Out-String which then displayed the contents of the array as expected.

```powershell
$groups | Out-String
```

Finally if the -addGroups switch is specified I used a foreach loop to add the groups that are selected from the Out-Gridview window and add them to the device. To provide an element of error handling in case the decision is made not to add any groups the $groupsToAdd variable is evaluated to confirm that it is not null, before prompting for credentials to add the selected group/s to the new computer.

```powershell
if ($addGroups) {
                
    $groupsToAdd = ($groupsToAdd = $groups | Out-Gridview `
    -Title "AD groups: == present on both, => unique to new `
    computer, <= unique to old computer" -passthru).Name
    
    if ($groupsToAdd) {

        Write-Verbose "Adding selected AD groups to `
	$newComputer"s
                    
        $credentials = Get-Credential

        foreach ($group in $groupsToAdd) {
            Add-ADGroupMember -Identity $group -Members `
	    $newComputer$ -Credential $credentials
        }
    }
                Write-Verbose "Selected AD groups now added `
		to new computer"
}
```
Below is the Out-Gridview window with the results of the functions queries with 2x AD groups selected to be added to the new device.

![Out-Gridview](/images/CompareGUI_mu.png)

## Conclusion
I'm really happy with how this function came together, it provides the ability to both compare AD group memberships only or flexibly select and add one or more AD groups to the new device via a GUI interface.

Below are some links to the documentation and other references I used when creating this function.

- Bas Bossink - PowerShell hashtable content not displayed in a function [StackOverflow](https://stackoverflow.com/questions/13353300/powershell-hashtable-content-not-displayed-within-a-function)
- Thomas Maurer - Powershell: check variable for null [Blogpost](https://www.thomasmaurer.ch/2010/07/powershell-check-variable-for-null/)
- Microsoft Docs - PowerShell Get-Credential [Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-7.2)
