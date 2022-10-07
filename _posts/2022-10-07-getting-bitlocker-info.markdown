---
title:  "Use Powershell to Retrieve BitLocker Keys"
date:   2022-10-07 17:37:56
categories: [PowerShell]
tags: [PowerShell]
---

I've been using a function to retrieve BitLocker keys from Active Directory which up until recently I believed to work without issue. The function was designed to find all BitLocker keys for a given device and then sort them by the whenCreated property and then return the newest record.

```powershell
$obj = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase $computer -Properties whenCreated, msFVE-RecoveryPassword -Credential (Get-Credential) | Sort-Object whenCreated -Descending | Select-Object whenCreated, msFVE-RecoveryPassword

            [Ordered]@{
                ComputerName  = $computerName
                EncryptedDate = $obj.whenCreated[0]
                BitLockerKey  = $obj.{msFVE-RecoveryPassword}[0]
            }
```

This had always returned the expected results until I came across a device that only had one key present, instead of the whole key being returned only the first number of the key was returned. Initially I discounted this issue as an anomally with that particular device when the issue was again encountered I grew suspicious that there was an issue that needed investigation.

I quickly realised that the issue was that when only one BitLocker key present as there was only one item in the array returned by the query. The way the output to the console was structured only the first number of the key would be returned. Having determined the root cause of the issue, I started to try and logically determine how I could test if there was only one key returned by the initial Get-ADObject enquiry.

```powershell
$obj.GetType()

IsPublic IsSerial Name      BaseType
-------- -------- ----      --------
True     False    ADObject  Microsoft.ActiveDirectory.Management.ADEntity
```
This object type did not have any inbuilt methods that could be leveraged. With this option eliminated I then turned to how my query was structured and what options I had to control the output of the complete BitLocker key.

Reading the help documentation for the Select-Object cmdlet I discovered that there was a -First parameter that "Specifies the number of objects to select from the beginning of an array of input objects". I changed the query to specifically select the first item in the array once it had been sorted by dateCreated. Now in the hash table that is returning the values there is no need to manually specify which item in the array should be returned. The amended query is below.
 
```powershell
$obj = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase $computer -Properties whenCreated, msFVE-RecoveryPassword -Credential (Get-Credential) | Sort-Object whenCreated -Descending | Select-Object -First 1

[Ordered]@{
               ComputerName  = $computerName
               EncryptedDate = $obj.whenCreated
               BitLockerKey  = $obj.'msFVE-RecoveryPassword'
            }
```

This change has now resolved the issue and the correct full BitLocker Recovery key is returned regardless of the number of keys present in Active Directory. I've since encountered another issue where from some office locations the BitLockerKey is not returned at all. I believe that this is most likely due to the domain controller that I'm authenticated to in those locations not having the BitLocker Recovery information replicated to it. I intend to test this theory by manually specifying the domain controller to query as the Get-ADObject cmdlet has a -server parameter for the BitLocker recovery information to confirm if that resolves the issue.

## Conclusion
This proved to be a reasonably straight forward issue to resolve once I discovered the -First parameter option for Select-Object. The initial option I was going to use to address the issue was using an 'if' statement to check the length of the $obj.'msFVE-RecoveryPassword' property and then determine what action to take, but ultimately the solution I ended up using was far less complex and much easier to implement.

Below are some links to the documentation and other references I used when resolving this issue.

Microsoft Docs - PowerShell Select-Object [Documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.2)
