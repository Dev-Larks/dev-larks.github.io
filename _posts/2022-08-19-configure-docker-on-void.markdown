---
title:  "Install and Configure Docker on Void Linux"
date:   2022-08-19 10:29:42
categories: [docker]
tags: [Linux, Void, Docker]
---

I've invested most of this month reading about Docker to better understand the technology. The primary purpose behind this exercise was to create a static text based website in a Docker container with recipes that we commonly use for meals. Prior to this investment my knowledge of Docker was limited and my initial approach was to mount a local folder in the Docker container as a volume which held the html pages for the website. I could modify the content of the local folder and get these changes reflected in the container. I quickly realised that this approach didn't leverage the advantages of using Docker and the ephemeral nature of containers as a whole. In conjunction with this I've also been configuring Void Linux as my new primary OS and recreating my configurations to be suitable for a Runit init system.

This post focuses on the install and configuration of the required services for Docker on Void Linux. Void has a version of Docker available in the standard repositories and the process to install was very straight forward.

```bash
sudo xbps-install docker
Password:

Name       Action    Version           New version            Download size
docker-cli install   -                 20.10.17_1             10MB
runc       install   -                 1.1.3_1                3024KB
containerd install   -                 1.6.6_1                32MB
moby       install   -                 20.10.17_1             20MB
tini       install   -                 0.19.0_1               299KB
docker     install   -                 20.10.17_1             544B

Size to download:               65MB
Size required on disk:         218MB
Space available on disk:        82GB

Do you want to continue? [Y/n]
```
Executing docker --version in the terminal confirmed Docker was now installed.

```bash
docker --version
Docker version 20.10.17, build tag v20.10.17
```

With Docker successfully installed the docker and containerd services had to be enabled, my preference is to manually enable these services when needed rather than have them autostart at boot. In Void the services that are present on a machine are located in the /etc/sv directory, to enable a service you just need to create a symlink to the /var/service directory. I also created an empty file called 'down' to stop the Docker services from being started at boot time as per the Void Linux documentation.

```bash
touch /etc/sv/docker/down
touch /etc/sv/containerd/down

sudo ln -s /etc/sv/docker /var/service
sudo ln -s /etc/sv/containerd /var/service
```

A quick check of the service status shows that while both services are now linked their status is down. Executing the 'sv once' command each of the services is started and their state re-evaluated.
```bash
sudo sv status /var/service/* | grep down
down: /var/service/containerd: 55s
down: /var/service/docker: 66s; run: log: (pid 19916) 66s

[craig][~]-> sudo sv once docker
[craig][~]-> sudo sv once containerd

sudo sv status /var/service/* | grep -e 'docker\|containerd'
run: /var/service/containerd: (pid 20696) 213s, normally down, want down
run: /var/service/docker: (pid 20513) 223s, normally down, want down; run: log: (pid 19916) 340s
```

The docker and containerd services state are managed via two shell scripts that I've created that use the sv up and sv down commands to start and stop them as needed. Both use a familiar PowerShell verb-noun syntax (start-docker & stop-docker). I've also created a get-docker script to get the current service state.

The Docker install process on Void Linux doesn't create a group that you can add your user to. Due to this limitation all Docker commands need to be executed with 'sudo'. Below I verify I have a working Docker installation by pulling down the latest version of the Alpine Linux container from Dockerhub. I intend to use Alpine as the base for my website container.

```bash
sudo docker run --rm -ti alpine:latest /bin/sh
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
213ec9aee27d: Pull complete
Digest: sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad
Status: Downloaded newer image for alpine:latest
/ #
/ # cat /etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.16.2
PRETTY_NAME="Alpine Linux v3.16"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://gitlab.alpinelinux.org/alpine/aports/-/issues"
/ #
```

## Conclusion
With Docker now successfully installed on my laptop, I am going to continue to read through the remaining chapters of the two reference books that I have access to, Docker Up & Running and Docker in a Month of Lunches. By the end of this process I want to have a static website running in a container on my Raspberry Pi that is built and managed using Docker best practices.


## Resources
Void Linux service configuration - [Documentation](https://docs.voidlinux.org/config/services/index.html)

