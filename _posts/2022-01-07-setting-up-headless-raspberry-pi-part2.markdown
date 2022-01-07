---
title:  "Setting up a Headless Raspberry Pi - Part 2"
date:   2022-01-07
last_modified_at:
categories: [raspberrypi, blog]
tags: [Raspberry Pi, Pi-Hole, Portainer, Docker, blog]
---

The second post in this series covers the install of Pi-Hole on Docker using Portainer, it covers the manual configuration of the Pi-Hole template in Portainer and configuration of the Pi-Hole application post the Docker container being deployed. The build process was completed following the excellent documentation on the Pi-Hole project website.

### Configure Pi-Hole Template in Portainer

After opening the Portainer webgui and authenticating, from the Portainer dashboard I clicked on 'Local > Containers' and clicked on the '+ Add Container' button. The 'Create container' page loaded and the below configuration settings were applied based on the sample Docker compose file in the Pi-Hole DockerImage documentation:

#### Image Configuration
- Name: Pi-Hole
- Image: pihole/pihole:latest

#### Advanced Container Settings
#### Volumes
Two Docker 'bind' volumes were created as these allow the host directory paths to be mounted in the container to be explicitly specified.
- Container: /etc/pihole
- Host: /home/admincl/Docker/DockerVol/Pi-Hole/etc

- Container: /etc/dnsmasq.d/
- Host: /home/admincl/Docker/DockerVol/Pi-Hole/dnsmasq

#### Network
My ISP provided router doesn't support the capability to use DHCP to set the Pi-Hole as my DNS server for clients on the network. For simplicity I chose to use a host network, at a later time I plan to change this to a macvlan network.
- Network: host

#### Environment Variables
My timezone was set via an environment variable, this is used by the Raspberry Pi to rotate the logs and get the latest version of the block lists.
- Name: TZ
- Value: Australia/Sydney

#### Restart Policy
This was set to always restart the container unless it has been specifically stopped.
- Restart policy: Unless stopped

#### Capabilities
To enable the use of the DHCP capability in Pi-Hole 'NET_ADMIN' was enabled.

## Deploying the Pi-Hole Container
With the configuration of the Docker template complete I then clicked on 'Deploy the container. This process took approximately 3-4 minutes to complete before the Pi-Hole container moved from a 'Starting' state to the 'Healthy' state. The random password that was generated to access the Pi-Hole WebGUI was located by running the following command when connected to the Raspberry Pi via ssh.

```powershell
docker logs pihole | grep random
```

#### Pi-Hole Post Deployment Configuration

At this point I was able to sign into the Pi-Hole web gui and complete some additional manual configuration. In Settings > DNS I selected OpenDNS as the upstream DNS provider. I then configured the DHCP IP address range and router (gateway) IP address, with this complete I then enabled DHCP on the Pi-Hole.

To complete the configuration of my network to leverage the DNS sinkhole capability that Pi-Hole offers I logged into the web GUI of my router and disabled the DHCP server function.

Below are links to the documentation and resources that I utilised in the configuration process described in this post:
- Docker Pi-hole [Documentation](https://github.com/pi-hole/docker-pi-hole)
- Docker DHCP and Networks [Documentation](https://docs.pi-hole.net/docker/dhcp/)
- Docker Volumes [Documentation](https://docs.docker.com/storage/bind-mounts/)
- How to Install Pi-Hole on Docker with Portainer [Video](https://www.youtube.com/watch?v=XziNCmcxB_c)



