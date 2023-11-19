---
title:  "Creating a Jekyll Blogging Environment in Docker"
date:   2023-11-18 10:03:22
categories: [Docker, blog]
tags: [Docker, blog]
---

I've moved to using Void Linux as my primary distro, I've maintained an older Arch Linux install as my blogging environment. Last week the Research Triangle PowerShell Users Group posted a video of a presentation by Alain Assaf of how he manages his blog. One of the aspects of this was the use of a Docker container to develop posts in. This immediately captured my interest and I've spent this week working on developing a solution based on this implementation without using VS Code and the Docker extension. Links to all relevant resources are at the bottom of this page.

At this time I have a working Docker container that mounts my local Github pages site and allows me to view changes live in my web browser. The purpose of this post is to primarily capture and document the configuration that I'm using.

The Docker file is based off the work of Bill Raymond with no changes, initially I added vim as one of the packages installed, as I was then cloning my Github pages site into the container and editing things from there. But having worked out how to mount the local files in the container I can edit/create blog posts outside of the Docker environment and see the changes reflected.

I've also created a run-once.sh file again based on the work of Bill Raymond which installs a specific version of github pages, webrick, and installs/updates the gems that are required to generate my blog site. Additional configuration that I've made for my environment is below.

In my .bashrc file I've added the below alias
```bash
# Alias for launching Jekyll development environment
alias start-jekyll='docker run -it --volume "$(pwd):/dev-larks.github.io" -w /dev-larks.github.io  -p 8080:4000 dev-larks.github.io'
```
This allows me to easily start the Docker container from my blog site directory locally and specify the ports and image to use without having to remember the exact syntax to use. 
Once the container is running I then execute the run-once.sh to prepare the container to host my blogsite. 

```bash
#!/bin/sh
# Display current Ruby version
echo "Ruby version"
ruby -v

# Display current Jekyll version
echo "Jekyll version"
jekyll -v

# Configure Jekyll for GitHub Pages
echo "Add GitHub Pages to the bundle"
bundle add "github-pages" --group "jekyll_plugins" --version 228

# webrick is a technology that has been removed by Ruby, but needed for Jekyll
echo "Add required webrick dependency to the bundle"
bundle add webrick

# Install and update the bundle
echo "bundle install"
bundle install
echo "bundle update"
bundle update
```
Finally to bring up my blogsite the below command is executed

```bash
bundle exec jekyll serve --incremental --drafts --host 0.0.0.0
```

 
## Conclusion
This has been a fun project and I've enjoyed the challenge of thinking how I can apply the process in my environment. Overcoming issues that were encountered along the way, with locales information, mounting volumes in a container amongst them. The locales issue was resolved by implementing the run-once.sh script that Bill Raymond had. Adding the webrick dependency resolved these errors and removed the need to specify these values in my start-jekyll bash alias. I'm still interested in looking at the Plaster template to create new posts and need to see if I can get PowerShell 7 working in Void or if I install PowerShell 7 in the Docker image.


Below are some links to the documentation and other references I used when resolving this issue.

- Creating a workflow for blogging [Alain Assaf](hhttps://alainassaf.com/2023-10-12-automation-me/?utm_source=blog&utm_medium=blog&utm_conte    nt=recent#docker)
- Develop Github Pages locally in a Ubuntu Docker Container [Bill Raymond](https://www.youtube.com/watch?v=zijOXpZzdvs)
- Broken urls in Jekyll in Docker [stackoverflow](https://stackoverflow.com/questions/57933583/broken-urls-in-jekyll-in-docker)
