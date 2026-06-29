---
title:  "Monitoring Server Health Post Patching"
date:   2026-02-06
categories: [PowerShell]
tags: [PowerShell]
---
The organisation which I currently work for uses Microsoft Configuration Manager (MCM) to deploy the monthly security patches to our server fleet. We don't have a server monitoring solution that monitors all of the servers that my team is responsible for. The server patching cycle as currently configured takes two weeks to complete. My team uses a PowerShell script which executes under a daily scheduled task to complete a daily check on the uptime status of all servers across our fleet.

The script is quite long and to be honest has functions that I don't fully understand how they calculate the values that are produced. At it essence it writes output to a series of text files, the output of each is then combined and placed in the body of an email which is sent to all the members in my team. Each time it runs it reads a list of server names and then trys to ping them if a response was received the server name was written to a specifc file if it is offline the name was written to a different file. The script then proceeds to check the servers that were reported as offline and confirms if the server was also reported as offline the day before. A server that has been reported as offline for more than four days is then removed from the main list of server names to check. On the first day it is reported as a new outage for subsequent days as a continued outage. The script then next queries the servers that are online and checks to see their last reboot time, if the reboot time is within 24 hours of the time the monitoring script was executed this information is written to a restart file. Once this step has been completed the script then combines the content of the various text files it creates and produces the body of a text based email which is sent to the staff in my team. An example of the output of the script in its original state is shown below.

Please resolve any issues with server health as advised below. The data represents a comparison of server connectivity between yesterday and today. If servers have reported offline for 4 consecutive days, they will be transferred from the input file to an exception file and no longer be checked.

________________________________________________________________________________________
< Server connectivity report for deployment group PRD-1.3-AWS-WK1FRI comparing FRIDAY to SATURDAY >

!! Outage: Server AMAPRDSRVMS01A.steeltown.local was online on FRIDAY, offline on SATURDAY.
!! Outage: Server AMAPRDSRV05A.steeltown.local was online on FRIDAY, offline on SATURDAY.
Restoration: Server AMAPRDSRVGP01A.steeltown.local was offline on FRIDAY, online on SATURDAY.

< Server Restarts within 24 hours of 18-10 07:00:02 >

________________________________________________________________________________________
< Server connectivity report for deployment group PRD-1.3-AZ-WK1FRI comparing FRIDAY to SATURDAY >


< Server Restarts within 24 hours of 18-10 07:00:02 >

Server PAZSRVWE4004.dec.int was restarted at 18-10 01:00:39.
Server PAZSRVWI4002.dec.int was restarted at 18-10 00:00:27.


________________________________________________________________________________________
< Servers in SCCM with no DNS record >


_____________________________________ END OF REPORT _______________________________________


There were a couple of issues with the script, primarily the logic that was used to calculate the Sunday after patch Tuesday did not correctly work for every month of the year which caused the script to not execute correctly on certain months. The second item which was the main driver from my perspective was that given that the email body was text it was often difficult to discern information and things were missed. I wanted to convert the output that was sent to html so that servers that were offline or restored after an outage could have html styles applied to them to make these events easier to see.

There were a few false starts for issues with writing server names to the text files and then trying to incorporate the desired html tags and formatting. My initial approach was to try and manipulate the content of the text files after the information had been written and add the html tags around the server names I struggled to get a working solution for this approach but as part of working on trying to get this to work I came across a post about PowerShell here strings. Which based on what I wanted to do looked to be the perfect solution, within the PowerShell script I could use these to template out the desired html tags and then just insert the server names as required. This proved to be the perfect solution to the challenges that I had been facing to produce html output.

I wrestled with putting the text file output into a html table so that the email body was nicely structured. While there are still some minor issues that I've not been able to resolve and I'm sure that my approach is probably less than optimal I had the script generating readable html output. For outages it formats server names for servers that are offline today but were online yesterday in red, servers that have been offline for 1 or more days are listed in orange, and servers that were reported as offline the day before but online today in green.

A screenshot of the output of the report now is shown below.
![HTML Report](/images/patchingchecker.png)

The second part of the exercise to reliably determine the first Sunday after patch Tuesday was a very simple solution I don't generally use AI suggestions from the web but in this case it has worked flawlessly. Below are the two unreliable original methods that were used, they had to be switched around as required each month to ensure that the correct Sunday was calculated.

```powershell
#Original - Calculate Sunday after Patch Tuesday
$currentDate = Get-Date
$firstDayOfMonth = Get-Date -Day 1 -Month $currentDate.Month -Year $currentDate.Year
$secondSunday = $firstDayOfMonth.AddDays((6 - $firstDayOfMonth.DayOfWeek + 7) % 7 + 7)

#Calculate Sunday after Patch Tuesday
#$weekDay = 'Tuesday'
#[datetime]$now = [datetime]::NOW.AddDays(7)
#$month = $now.Month.ToString()
#$year = $now.Year.ToString()
#[datetime]$strtMonth = $month + '/1/' + $year
#while ($strtMonth.DayofWeek -ine $weekDay ) { $strtMonth = $StrtMonth.AddDays(1) }
#$secondSunday = $strtMonth.AddDays(12)
```

This is the new function that addresses the shortfall of the original methods.
```
function Get-SaturdayAfterPatchTuesday {
  Param (
    [int]$Month = (Get-Date).Month,
    [int]$Year = (Get-Date).Year
  )

  # Get the first day of the specified month
  $firstDayOfMonth = Get-Date -Year $Year -Month $Month -Day 1

  # Find the first Tuesday of the month
  $currentDate = $firstDayOfMonth
  while ($currentDate.DayOfWeek -ne [DayOfWeek]::Tuesday) {
    $currentDate = $currentDate.AddDays(1)
  }

  # Patch Tuesday is the second Tuesday of the month
  $patchTuesday = $currentDate.AddDays(7)

  # Find the next Saturday after Patch Tuesday
  $saturdayAfterPatchTuesday = $patchTuesday
  while ($saturdayAfterPatchTuesday.DayOfWeek -ne [DayOfWeek]::Saturday) {
    $saturdayAfterPatchTuesday = $saturdayAfterPatchTuesday.AddDays(1)
  }

  return $saturdayAfterPatchTuesday
}
```

Without a doubt this has been the most technically challenging PowerShell project that I have worked on, and I have to acknowledge and admire the work of the original person who created the script. My changes are predominantly related to the format of the text that is written to the text files and 100 percent stands upon the shoulders of giants who went before me.
