---
title:  "PowerShell Function from Scratch to Final"
date:   2026-06-04
categories: [PowerShell]
tags: [PowerShell]
---
We currently have a project running in our environment to decommission two of the three Active Directory (AD) domains that we have and consolidate down to a single AD domain. As part of this project my team has been responsible for the migration of servers from the domains that will be decommissioned. As part of this work we need to complete a level of server discovery to find services, tasks etc that are being run by domain accounts so that appropriate planning can be completed to ensure the domain migration process is as smooth as possible. While I have put together a list of PowerShell commands that can be used to complete this discovery this post is to show the progress of the command that I used to capture information about any Scheduled Tasks that are configured on a server.

Using the Get-ScheduledTask cmdlet was an obvious place to start, and returns a full list of all scheduled tasks, provided that you run the cmdlet in an Administrator PowerShell window. However it also includes all of the tasks that are configured in the default Microsoft directory in Task Scheduler. For my purposes I didn't need this information so my first iteration of getting this information was using the below which explicitly excludes the Microsoft directory and any disabled tasks.

```powershell
Get-ScheduledTask | where { ($_.TaskPath -NotLike '\Microsoft\*') -and $_.State -eq 'Ready' }  

TaskPath                     TaskName                                                                        State
--------                     --------                                                                        -----
\                            Adobe Flash Player PPAPI Notifier                                               Ready
\                            Adobe Flash Player Updater                                                      Ready
\                            MicrosoftEdgeUpdateTaskMachineCore                                              Ready
\                            MicrosoftEdgeUpdateTaskMachineUA                                                Ready
\                            npcapwatchdog                                                                   Ready
\                            Optimize Start Menu Cache Files-S-1-5-21-2721282484-2951877577-328924344-102477 Ready
\                            Optimize Start Menu Cache Files-S-1-5-21-2721282484-2951877577-328924344-185682 Ready
\                            Optimize Start Menu Cache Files-S-1-5-21-2721282484-2951877577-328924344-233459 Ready
\                            Optimize Start Menu Cache Files-S-1-5-21-2721282484-2951877577-328924344-343847 Ready
\                            Optimize Start Menu Cache Files-S-1-5-21-2721282484-2951877577-328924344-367943 Ready
\                            Optimize Start Menu Cache Files-S-1-5-21-2721282484-2951877577-328924344-388130 Ready
\                            Patching Group Pre-Post Check                                                   Ready
\                            PROD - Patching Group Pre-Post Check                                            Ready
\                            SensorFramework-LogonTask-{d2bf6ee0-91cf-5437-e6a2-61286b7b7159}                Ready
\                            unlock                                                                          Ready
\                            User_Feed_Synchronization-{07E11E80-FF0D-471F-8A66-22D7103E65BF}                Ready
\                            User_Feed_Synchronization-{14C277E6-6F8B-44D9-ADFC-E9F593E2F9C8}                Ready
\                            User_Feed_Synchronization-{1F252E7C-F979-474F-AFC9-C2AAB06EF3F0}                Ready
\                            User_Feed_Synchronization-{55166580-C6A2-4123-A264-C2C0C3DFA769}                Ready
\                            User_Feed_Synchronization-{98227615-CE83-4E6E-BB15-CB7A75B5032F}                Ready
\                            User_Feed_Synchronization-{B293DE61-125E-4DB3-AF81-B02A52CBC420}                Ready
\                            User_Feed_Synchronization-{B5BE1EF9-A047-4B7B-91AA-F8FDCE38EE0A}                Ready
\                            User_Feed_Synchronization-{BDB7C6BA-3C34-4151-9E66-2BC85E353688}                Ready
\                            User_Feed_Synchronization-{F3D228B0-CAEB-4273-B738-F15F7EA747B9}                Ready
\                            User_Feed_Synchronization-{FADFC7BD-A130-4E47-A8AA-C154EE590548}                Ready
\GoogleSystem\GoogleUpdater\ GoogleUpdaterTaskSystem150.0.7863.0{F470678A-AB11-41D0-ABA4-7C794DCFD3D7}       Ready
\GoogleUserPEH\              RunPlatformExperienceHelper_Daily                                               Ready
\GoogleUserPEH\              RunPlatformExperienceHelper_Metrics                                             Ready
```

This greatly reduced the output but still contained information that wasn't of interest to the use case that I had. After looking at the additional properties that were available from the standard Get-ScheduledTask cmdlet I added the Author property and based on this output. With this information I re-wrote the command and specifically excluded where the Author name was null, started with Microsoft or with $ and started with The major. Again I only output the scheduled tasks that were then not disabled. 

Get-ScheduledTask | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Author) -and ($_.Author -NotLike "Microsoft*") -and ($_.Author -NotLike "$*") -and ($_.Author -NotLike "The major*") -and $_.State -eq 'Ready' } | Select-Object TaskName, Author, TaskPath, State

This removed all of the Microsoft authored tasks but still included some which were irrelevant such as the Adobe, GoogleUpdater. There were some other domain level tasks which were present on all servers but not relevant to the domain that the servers would be migrated to. I further expanded the exclusions to include some additional TaskName values, oddly at this time I then ended up with two versions of the script one that included only active tasks and another that included disabled tasks. I had decided to also capture disabled tasks as I had found multiple instances where there were disabled tasks that were executed by a domain account and I was uncertain why the tasks were disabled and if they may be re-enabled at some point in a then broken state.

```powershell
Get-ScheduledTask | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Author) -and ($_.TaskName -NotLike "Adobe*")  -and ($_.TaskName -NotLike "DCAgent*") -and ($_.TaskName -NotLike "Deploy Crowd*") -and ($_.TaskName -NotLike "GoogleUpdater*") -and ($_.TaskName -NotLike "RunPlatform*") -and ($_.TaskName -NotLike "User*") -and ($_.Author -NotLike "Microsoft*") -and ($_.Author -NotLike "$*") -and ($_.Author -NotLike "The major*") -and $_.State -eq 'Ready' } | Select-Object TaskName, Author, TaskPath, Arguments, State
```

```powershell
Get-ScheduledTask | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Author) -and ($_.TaskName -NotLike "Adobe*")  -and ($_.TaskName -NotLike "DCAgent*") -and ($_.TaskName -NotLike "Deploy Crowd*") -and ($_.TaskName -NotLike "GoogleUpdater*") -and ($_.TaskName -NotLike "RunPlatform*") -and ($_.TaskName -NotLike "User*") -and ($_.Author -NotLike "Microsoft*") -and ($_.Author -NotLike "$*") -and ($_.Author -NotLike "The major*") -and $_.State -eq 'Disabled' } | Select-Object TaskName, TaskPath, Author, State
```

The final version of the discovery script was a further iteration of the above, I removed any check of the scheduled task state given that I wanted to capture both enabled and disabled. I then started to dig deeper wanting to capture what executable or script was being run by the task. I discovered that you could use calculated properties in PowerShell to gain access to the nested values in the Actions object which are not visible in the standard console output. Interestingly I had to add both Execute and Arguments as depending upon the scheduled task the actual action/script to be executed would be visible in either of these values.

```powershell
Get-ScheduledTask | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Author) -and ($_.TaskName -NotLike "GoogleUpdater*") -and ($_.TaskName -NotLike "Deploy Crowd*") -and ($_.TaskName -NotLike "DCAgent*") -and ($_.Author -NotLike "Microsoft*") -and ($_.Author -NotLike "$*") -and ($_.Author -NotLike "The major*") } | Select-Object TaskName, TaskPath, @{
    Name = 'UserId'
    Expression = { $_.Principal.UserId }
}, @{
    Name = 'Actions'
    Expression = { $_.Actions.Execute }
}, @{
    Name = 'Arguments'
    Expression = { $_.Actions.Arguments }
}, State
```

I found the reflection on my thought processes during the development of this script interesting as I wrote this blog post. Particularly as what I thought was important to capture continued to evolve. While I seldom do this it does show that before beginning to develop any solution it is worthwhile to invest the time to consider the use case and determine exactly what information you want to capture and display.



*Thanks for Reading,*
*Craig*

### Sources
Below are the sources that I referenced when developing this script.

- Microsoft Learn - [Help Get-ScheduledTaskInfo](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/get-scheduledtaskinfo?view=windowsserver2025-ps
