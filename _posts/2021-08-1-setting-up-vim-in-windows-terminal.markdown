---
title:  "Configuring Vim in Windows Terminal"
date:   2021-08-01
categories: [powershell, vim, blog]
tags: [Vim, PowerShell, Windows Terminal, blog, Nord Theme]
---

I had installed Vim but unlike in Linux had never really used it in Windows. My primary motive for revisiting this was VimWiki, I was keen to move away from using OneNote Online for my personal notes. Looking for an environment that was similar to Linux I initially installed the Windows Subsystem for Linux WSL2 and installed Arch. While trying to determine how I could load vim plug-ins in that environment I stumbled across another guide from freeCodeCamp that outlined how to set it up in PowerShell.

### Install gVim
I tested my existing installation and Vim would not open from PowerShell or the Command Prompt. I located the installer I had downloaded previously and ran the installer again and selected the Full install option. At the completion of this process I tested and confirmed that vim did now open in Windows Terminal in PowerShell. I was happy that using this process Vim continued to use my default terminal Nord colour profile.

### Install vim-plug
To increase the functionality of Vim I wanted to add a plugin manager so I followed the install instructions for vim-plug and executed the below code in PowerShell.

```powershell 
    iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
```

This created the below folder structure in my user profile:

![Initial state of Windows Terminal](/images/VPS_001.png){: .centre-image}

### Create vimrc
To manage the configuration of Vim I needed to create a vimrc file. It took some reading of the initialisation section of both the VIM reference manual and the Vim-Plug help documentation to understand where this file should be located in Windows. My next challenge was then using the correct syntax in the vimrc file so that calling the :PlugInstall command within Vim to install the configured plugins worked. In the end a very simple configuration structure was enough to get me up and running, opening the Vim configuration file is as easy as opening Vim and then typing ':edit $MYVIMRC' and pressing the Enter key. 

```vim
call plug#begin()

Plug 'arcticicestudio/nord-vim'

" Plug 'vimwiki/vimwiki

" Initialize plugin system
call plug#end()
```

### Conclusion
One of my challenges for the remainder of 2021 is to become more efficient with using Vim as my primary notetaking solution. The ability to use Vim during my normal work day is going to help in this transition as I always have the Windows Terminal open with PowerShell. I've added some additional Vim plugins primarily VimWiki to manage my notes and NERDTree which is a visual file system explorer. These were easily added by adding two lines to my vimrc and leveraging the functionality of vim-plug.


#### Sources
Below are links to the documentation and files I referenced to configure Vim in PowerShell:

- Quincy Larson - Vim Windows Install Guide - How to Run the Vim Text Editor in PowerShell on your [PC](https://www.freecodecamp.org/news/vim-windows-install-powershell/)
- Vim Plug [Documentation](https://github.com/junegunn/vim-plug)
- Vim help [files](https://vimhelp.org/starting.txt.html#initialization)
