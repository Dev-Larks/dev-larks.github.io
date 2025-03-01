---
layout: post
title: "Using PowerShell for Date Value Manipulation"
date: 2025-03-01
categories: [PowerShell]
tags: [PowerShell]
---



I use PowerShell each month to generate the body text for emails that I send to specific business areas that provide a snapshot of the days and times that the maintenance windows will open for patching of their Windows servers. I have been generating this email output for many months aware of the fact that the logic I had implemented to calculate the dates was somewhat flawed. On months where patch Tuesday is closer to the 14th of the month the script can generate dates for patching that don't actually exist. I usually catch these errors and the manually update the dates, this month however being a short month I missed the error and sent my standard email with the final patching activity being shown as taking place on the 29th of February. A valid date for a leap year but not for February 2025, a day or two later I was queried by one of the recipients seeking confirmation of which day their servers would actually be patched.

To understand the source of the problem I'll show the original version of the function and then the changes that I implemented to address this issue. I use a Get-PatchTuesday function created by Travis Roberts that I found on Github. I had modified it slightly to return just the day of patch Tuesday rather than the original output. This function is called by the main function that I use to create my emails, below is the begin block of the Get-CM10ServerPatchDates function.

```powershell
function Get-CM10ServerPatchDates {
    [CmdletBinding()]
    param (

    )

    begin {

        #Get months Patch Tuesday date
        $PatchTuesday = Get-PatchTuesday

        #Get current month and year
        $PatchingMonth = get-date -Format "MMMM yyyy"

        #Get final patch release inclusion date
        $PatchesReleasedUpTo = "$PatchTuesday " + "$PatchingMonth"

        #Records group specific patching dates
        $cm10NonProdDev = $PatchTuesday + 6
        $cm10Prod1 = $PatchTuesday + 10
        $cm10NonProdTst = $PatchTuesday + 13
        $cm10Prod2 = $PatchTuesday + 18

    }
```
```powershell
Function Get-PatchTuesday {
    [CmdletBinding()]
    Param
    (
      [Parameter(position = 0)]
      [ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")]
      [String]$weekDay = 'Tuesday',
      [ValidateRange(0, 5)]
      [Parameter(position = 1)]
      [int]$findNthDay = 2
    )
    # Get the date and find the first day of the month
    # Find the first instance of the given weekday
    [datetime]$today = [datetime]::NOW
    $todayM = $today.Month.ToString()
    $todayY = $today.Year.ToString()
    [datetime]$strtMonth = $todayM + '/1/' + $todayY
    while ($strtMonth.DayofWeek -ine $weekDay ) { $strtMonth = $StrtMonth.AddDays(1) }
    $firstWeekDay = $strtMonth

    # Identify and calculate the day offset
    if ($findNthDay -eq 1) {
      $dayOffset = 0
    }
    else {
      $dayOffset = ($findNthDay - 1) * 7
    }

    # Return date of the day/instance specified
    $patchTuesday = $firstWeekDay.AddDays($dayOffset)
    return $patchTuesday.Day

  }
```

The original script returns the below information

```powershell
Tuesday, 11 February 2025 12:00:00 AM
```

I had modified this by returning $patchTuesday.day to return just the number of day that patch Tuesday fell on for the month.

```powershell
11
```

Having changed the output of the Get-PatchTuesday back to returning the full datetime object I wanted to just use this one variable and then remove the date values that I didn't need depending on where I was using the date in the function. I was fortunate to find a single Stackoverflow question that provided code to meet all my requirements. The most popular answer in this thread provided me with a .NET method to extract just the day number from the $patchTuesday variable. Providing a valid way to replace the old variable value that the initial Get-PatchTuesday function originally returned.

```powershell
$day = '{0:dd}' -f $patchTuesday
$day
11
```

I utilised the same .NET method to format the $PatchingMonth and $PatchesReleasedUpTo variables from the value returned from the Get-PatchTuesday function

```powershell
$PatchingMonth = '{0:MMMM yyyy}' -f $PatchTuesday
$PatchingMonth
March 2025

$PatchesReleasedUpTo = '{0:dd MMMM}' -f $patchTuesday
$PatchesReleasedUpTo
11 March
```

Finally to addres the way that I as calculating the patching dates for the actual Maintenance Windows I utilised another answer from the same Stackoverflow thread initially to calculate the patchind dates I was using the .AddDays() method and saving that to a variable before then using the .GetDateTimeFormats() to format the timedate object into the format that I wanted.

Initial
```powershell
$cm10NonProdDev = $PatchTuesday.AddDays(6)
$cm10NonProdDev = $cm10NonProdDev.GetDateTimeFormats()[11]
```

Final
```powershell
$cm10NonProdDev = $PatchTuesday.AddDays(6).GetDateTimeFormats()[11]
```

The final gotcha of this process was discovered once I was happy with the final product and haa pushed my changes to version control. I then rebuilt the module that contains the Get-CM10ServerPatchDates function, during my intial testing I noted that the dates were not being output in the format that I was expecting. I realised that the cause of this was that I developed the code in VSCode where I run PowerShell 7.5, but my default Terminal version of PowerShell is 5.1. After changing the format values in the .GetDateTimeFormats() method from [5] to [11] I was again getting the expected output.



I'm really happy with the work that I completed here, and met my intended goal of manipulating just a single variable value to get multiple different date formats to meet the needs of my function. In the process of making this blog post I further refined the code from what I originally had removing the need for the $day variable by altering the way I was calculating the $PatchesReleasedUpTo value.



*Thanks for Reading,*  
*Craig*

### Sources
Below are links to the key resources that I referenced when working through the process to refactor the way I was creating date/time objects in this blog post.

- Travis Roberts - Get-PatchTuesday function [GitHub](https://github.com/tsrob50/Get-PatchTuesday/blob/master/Get-PatchTuesday.ps1-- fjsa)
- orad - How to format a DateTime in PowerShell [Stackoverflow](https://stackoverflow.com/questions/2249619/how-to-format-a-datetime-in-powershell)
- DateTime.GetDateTimeFormats Method .NET 9 [Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/api/system.datetime.getdatetimeformats?view=net-9.0)


