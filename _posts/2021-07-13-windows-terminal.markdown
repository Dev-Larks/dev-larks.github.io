---
title:  "Install and Configure Windows Terminal"
date:   2021-07-13
categories: [PowerShell, blog]
tags: [PowerShell, Windows Terminal, blog, Nord Theme]
---

I had to wait some time after the Windows Terminal was released before I could begin to use it as my organisation were not using a supported version of Windows 10. Inspiration on getting this up and running was provided by a tweet from [Marc Duiker](https://twitter.com/marcduiker/status/1380900166534885380) of a really nice terminal implementation that he had made.

### Pre-requisites
- Install the latest version of Windows Terminal from the Microsoft Store.
- Install the latest version of PowerShell 7 from the Microsoft Store (optional).
- Download and install the latest version of git.
- Install CasKaydiaCove NF from https://www.nerdfonts.com/font-downloads

I chose to install both programs from the Windows Store as they are then automatically updated as new versions are released.
The downloaded CasKaydiaCove font (four files) were installed only for my user profile which does not require administrative access to complete.

Next I installed the Posh-GIT and Oh-My-Posh modules from the PowerShell Gallery.

```powershell
 Install-Module -Name posh-git -Scope CurrentUser
 Install-Module -Name oh-my-posh -Scope CurrentUser
 Install-Module -Name terminal-icons -Scope CurrentUser
```

I then opened the Windows Terminal and ran "code $PROFILE" to create a PowerShell profile and open in in Visual Studio Code where I added the below lines.

```powershell
 # Setup PoshGit
 Import-Module posh-git

 # Setup up Oh-My-Posh
 Import-Module Terminal-Icons
 Import-Module oh-my-posh
```

Before I could successfully load a new PowerShell terminal I had to amend the PowerShell execution policy.
```powershell
 Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
 ```

Opening a new terminal instance was now successfully completed with no  PowerShell execution policy error messages but as the default terminal font had not been changed the Oh-My-Posh prompt was broken.
 
![Initial state of Windows Terminal](/images/ICWT_001.PNG){: .centre-image}
 
To access the Windows Terminal settings.json file I used the Cntl + , keyboard shortcut and then clicked on the "Open JSON file" option in the bottom left corner.

I then added the following lines to the default section of the Terminal settings.json file
```json
    "profiles": 
    {
        "defaults": 
        {
            "fontFace": "CasKaydiaCove NF",
            "fontSize": 14
        },
```
After closing and relaunching a new PowerShell terminal window I had a much nicer looking prompt and output. The Oh-My-Posh PowerShell module has alot of built in schemes which you can view in the terminal by running the Get-Posh themes cmdlet. At the time of writing this blogpost the theme that had originally inspired me to setup Windows terminal is now included by default "Theme: marcduiker".

![Default Windows Terminal](/images/ICWT_002.PNG){: .centre-image}

I'm a fan of the Nord colour scheme, and a quick search located a nord scheme from "Compiled Experience" which I added to the "schemes": section of my Windows Terminal settings.json file.
I then set the default colour scheme to be Nord in the powershell.exe profile section in the settings.json file.
```json
	{
	"commandline": "powershell.exe",
        "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
        "hidden": false,
        "name": "Windows PowerShell",
	"colorScheme": "nord"
	}
```
After saving and refreshing the terminal looked like this, I wasn't happy with the colours in the prompt itself so I went to the location where the Oh-My-Posh module is installed 

C:\Users\larkinc\Documents\WindowsPowerShell\Modules\oh-my-posh\3.168.0\themes

I created a custom prompt with elements that I liked from the marcduiker and iterm2 prompts, amending the colours to better align with the Nord colour scheme and saved the file with a unique name.

I also tweaked the Windows Terminal nord colour scheme slightly to make the black and brightBlack colour easier to read changing the hex value from #4C566A to #D8DEE9.

![Final Windows Terminal theme](/images/ICWT_003.PNG){: .centre-image}

Below are links to the documentation and files I used to create my custom Windows Terminal:

- Scott Hanselman - How to make a pretty prompt in Windows Terminal with Powerline, Nerd Fonts, Cascadia Code, WSL, and [oh-my-posh](https://www.hanselman.com/blog/how-to-make-a-pretty-prompt-in-windows-terminal-with-powerline-nerd-fonts-cascadia-code-wsl-and-ohmyposh)
- Scott Hanselman - Take your Windows Terminal and PowerShell to the next level with [Terminal Icons](https://www.hanselman.com/blog/take-your-windows-terminal-and-powershell-to-the-next-level-with-terminal-icons)
- Nigel Sampson - [Nord theme for Windows Terminal](https://compiledexperience.com/blog/posts/windows-terminal-nord)
- Oh My Posh [Documentation](https://ohmyposh.dev/docs/)
- Posh-Git [Documentation](https://github.com/dahlbyk/posh-git)
- MarcDuiker - [Oh My Posh 3 Theme](https://gist.github.com/marcduiker/43430c721670e1fd29068d441db230e1)
