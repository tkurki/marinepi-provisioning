MarinePi
========

[Ansible](https://en.wikipedia.org/wiki/Ansible_(software)) scripts to setup a Raspberry Pi for boat use, providing access to various data sources on board both via wired and wireless connections. Features include:
- [Signal K](http://signalk.org/) [node server](https://github.com/SignalK/signalk-server-node) with NMEA0183 and NMEA 2000 support
- wifi hotspot
- (marina) wifi access with routing
- 3/4G Internet connectivity with Huawei e3372
- VPN access
- various dynamic dns providers (inadyn, Route 53)
- read-only root partition

Usage
=====

1. [Install Ansible](http://docs.ansible.com/ansible/intro_installation.html) on your local computer
1. [Initialize a memory card](https://www.raspberrypi.org/documentation/installation/installing-images/) with the latest [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/)
  - `diskutil list`
  - `diskutil unmountDisk /dev/<disk#>`
  - `sudo dd bs=1m if=<your image file>.img of=/dev/<disk#>`
1. [Enable ssh](https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/) for Raspbian headless operation
  - `touch /Volumes/boot/ssh`
1. Connect the to-be-provisioned Raspberry Pi to the local network.
1. Run either `./firstrun.sh` (uses hostname `raspberrypi.local`) or `./firstrun.sh <ip-of-your-raspi>` ([find out the IP address](https://www.raspberrypi.org/documentation/remote-access/ip-address.md)) to copy over your [ssh key](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md) & do the initial setup (change password for user `pi`, copy the ssh key, expand the filesystem)
1. When it asks you for SSH password type in `raspberry` (default password for `pi` user) and hit return.
1. When asked for a new password what you enter will be the new password for the `pi` user on the device.
1. Edit configuration in `example-boat.yml` to match your environment and fill in your hotspot details
1. Run `./provision.sh <ip-of-your-raspi> example-boat.yml` to provision the software & configurations for the roles in example-boat.yml.


Roles
=====

You define what features you want to provision by adding roles to your playbook.

signalk
-------
Installs the Signal K Node server under /opt/signalk. Uses `node` and `node-app` roles to install Node.js and run under systemd.

hotspot
-------
Installs and configures the software needed for the Pi to act as a wifi hotspot. Override variables:
```
hotspot_ssid: MarinePi
hotspot_channel: 11
hotspot_passphrase: NavigareNecesseEst
hotspot_interface: wlan0
```

canboat
-------
Installs canboat utilities to interface with the NMEA 2000 network.

route53-ddns
------------
Installs a cron script that periodically checks your external IP address and updates [Amazon's Route 53 name server information to act as dynamic DNS setup](https://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/). Installs Amazon's command line tools as a dependency.

For minimal priviledges you should create a limited AWS identity for use with this profile and attach the policy `AmazonRoute53FullAccess`. In your own playbook define variables
```
aws_access_key_id: 'YOUR_ACCESS_KEY_ID'
aws_secret_access_key: 'YOUR_SECRET_ACCESS_KEY'
```
with the information for this limited identity.

wificlient
----------
Installs and configures the software the Pi needs to act as a wifi client. Override variables:
```
wificlient_interface: wlan1
wificlient_networks:
  - ssid: defaultssid
    psk: defaultpassphrase
    priority: 1
    scan_ssid: 0
```
You can add multiple networks by repeating the last four lines, if needed.

pysk
----
Installs the pysk console client on the Pi. See: https://github.com/ph1l/pysk

grafana
-------
Installs grafana. Override variables:
```
grafana_admin_password: admin
grafana_secret: SW2YcwTIb9zpOOhoPsMm
grafana_port: 3000
```

Credits
=======

Fork of [original project](https://github.com/hkapanen/sailpi) with the intention of continuing work in this repo.
