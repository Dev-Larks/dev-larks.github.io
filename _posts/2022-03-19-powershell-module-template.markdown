---
title:  "My PowerShell Plaster Module Template"
date:   2022-03-19 11:16:42
categories: [PowerShell]
tags: [PowerShell, Plaster,Module]
---

Plaster is a PowerShell module scaffolding framework which allows you to create user defined PowerShell module layouts depending upon your needs. I spent yesterday revisiting the PowerShell Plaster template that I use when creating new PowerShell modules. I recently shared a module with some of my colleagues at work, one that is still under active development and subject to future change as code is refactored and new functions added. On Reddit I'd read a post where the idea of including a change log was mentioned to formally track these changes. In the past as the only active user of the tools I created I'd never considered this option, using my git commit messages to understand what I had changed.

As I'm now sharing my work with others I wanted an easy mechanism where anyone could get a high-level overview of the functionality changes between module versions. It made sense to add this functionality to the Plaster template that I use when creating a new module.

The key component of my Plaster PowerShell template is the PlasterManifest.xml file which defines the module schema and the directories and files PowerShell creates based on your selections. I've been reading the 'Building PowerShell Modules' ebook by Brandin Olin and my current manifest.xml file reflects the practices that are outlined in this book along with other ideas from blogposts that I've read. I use a folder structure that keeps public and private helper functions separate and builds a monolithic .psm1 file using a build script. 

Of the changes I made yesterday when refactoring the PlasterManifest.xml file the key one  was to group the common files such as the .gitignore, readme.md and new changelog.md files to a single multi-choice prompt where all of these files are included by default. Previously the manifest was structured in such a way that you were prompted to confirm the creation of each of these files individually. 

```xml
<parameter    name="CommonFiles" type="multichoice" prompt="Please choose the common files to include" default= '0,1,2'>
    <choice label="&amp;.gitIgnore"
        help="Adds a .gitignore file to the module root"
        value=".gitIgnore" />
    <choice label="&amp;ReadMe"
        help="Adds a ReadMe.md file to the module root"
        value="ReadMe.md" />
    <choice label="&amp;ChangeLog"
        help="Adds a ChangeLog.md file to the module root"
        value="ChangeLog.md" />
</parameter>
```

The other key change was to modify the Module.Build.ps1 file to include steps to update the Change Log each time the module version is bumped by either a Major, Minor, or Patch version change. One of the challenges was keeping a copy of the current ChangeLog. If a module is being rebuilt but there is no version change the existing version folder has all the existing content deleted as part of the module build process. 
Although the ChangeLog.md file could be excluded when Get-ChildItem is run this does not solve the problem of where to source the ChangeLog.md file from if a new module version is created. 
There are no doubt a multitude of ways that this could be managed. I decided to create a master ChangeLog.md file which has all version change information recorded into it as part of the build process and a copy of it is then moved to the new module version folder. This means that the full history of a module can be easily tracked.

```powershell
# Update Change Log
Set-Location ./Output
Add-Content ./*.md -Value "Version $moduleVersion"
$changeInfo = Read-Host -Prompt "Add Module Version Change Information:"
Add-Content ./ChangeLog.md -Value $changeInfo
copy-item -Path ./ChangeLog.md -Destination $versionOutputDir
```

One of the challenges I faced when defining this process was to capture the actual changes and write them to the ChangeLog.md file. Initially I was using the Invoke-Item cmdlet to open the ChangeLog.md with the idea that I could add the relevant version change notes and then close and the updated file would then be copied to the new moduleversion folder. 
However I discovered that PowerShell does not wait for whatever has been invoked to be completed before moving to the the next line of the build script. I did consider using the Start-Sleep cmdlet and setting some arbitary value but this solution would rely on me being able to focus and not be distracted before the time elapsed. I experimented with a couple of other options to try and manage this process but ultimately settled on using Read-Host. I'll acknowledge that this is not a perfect solution but it does ensure consistency of the ChangeLog content.


### Conclusion
At the moment I'm happy with what I have implemented so far, there may be other more elegant ways to achieve the same solution. But this was the best solution that I could implement with my current level of PowerShell knowledge. I'm sure that this template will continue to evolve the 'Building PowerShell Modules' book is only just over half complete. One of next things I want to work on to improve is to create seperate help files for each of the functions as currently these are all contained within each of the individual function.ps1 files.

#### Sources
Below are links to the key resources that I referenced to arrive at my current Plaster template configuration:

- My git repo - Plaster FullModuleTemplate [git](https://codeberg.org/Dev_Larks/craig.dev.Plaster/src/branch/master/FullModuleTemplate)

- David Christian - Working with Plaster [Blogpost](https://overpoweredshell.com//Working-with-Plaster/)
- Kevin Marquette - PowerShell: Adventures in Plaster [Blogpost](https://powershellexplained.com/2017-05-12-Powershell-Plaster-adventures-in/)
- Brandin Olin - Building PowerShell Modules [ebook](https://leanpub.com/building-powershell-modules)
- Plaster Github Repo [Documentation](https://github.com/PowerShellOrg/Plaster)

