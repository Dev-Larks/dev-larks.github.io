---
layout: post
title: "Scheduling Server Reboots with PowerShell"
date: 2025-12-22
readtime: true
tags: [powershell]
---

<!--more-->
I often have servers that need to be manually re-started to install pending updates, particularly when the updates have been manually installed using PowerShell. Our general practice is to manually restart these servers out of hours usually around 10pm but we have a small group of servers which have a narrower maintenance window configured between 2am and 4am. Some of the servers allow you to schedule a reboot using the inbuilt Windows functionality but on others this option is restricted by Group Policy. This restriction led me to investigate if server restarts to apply patches could be created on an adhoc basis as required.

My initial searches uncovered a post from back in 2014 where a user saltface had provided the below code to schedule an adhoc restart the following day and provided an immediate viable solution to my use case only requiring the Date.AddHours value to be changed to 2.

```powershell
shutdown -r -t ([decimal]::round(((Get-Date).AddDays(1).Date.AddHours(3) - (Get-Date)).TotalSeconds))
```

To restart a server at a time other than on the hour you can add the .AddMinutes property, the below code will schedule a restart at 2:30am the following morning.

```powershell
shutdown -r -t ([decimal]::round(((Get-Date).AddDays(1).Date.AddHours(2).AddMinutes(30) - (Get-Date)).TotalSeconds))
```

From there I then wondered if I could use the same kind of logic to schedule a reboot on the same day. Establishing that there were 3600 seconds in an hour some quick maths determined that if I wanted to schedule a restart at 11pm that 82800 seconds would of elapsed since midnight.

```powershell
3600 * 23
82800
```

To calculate the number seconds that had currently elapsed that day I discovered that you could use the TimeOfDay property from the Get-Date cmdlet which amongst other values captures the TotalSeconds elapsed. Casting both the seconds values as integers I then calculated the delay period by minusing the elapsed seconds from the target seconds. I could then provide the difference between those two values as the time period to wait until the scheduled restart was initiated later that day.

```powershell
$then = [int]82800
$TimeOfDay = (Get-Date).TimeOfDay
$now = [int]$TimeOfDay.TotalSeconds
$difference = $then - $now
shutdown -r -t $difference
```

This is super simple and will remove the need for me to manually initiate server reboots out of hours and also provides the functionality to easily change reboot time by changing the $then value to the required value.


****Thanks for Reading,*
**Craig*

### Sources
Below are the sources that I referenced when developing this tool.

- saltface - Restart a computer at a given time with PowerShell [StackExchange](https://superuser.com/questions/847571/restart-a-computer-at-a-given-time-with-powershell 
- archdeacon - Adding hours minutes and seconds to a time value [PowerShell.org](ttps://forums.powershell.org/t/adding-hours-minutes-and-seconds-to-a-time-value/9630)
