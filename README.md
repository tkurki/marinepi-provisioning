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

1. [Install Ansible](http://docs.ansible.com/ansible/intro_installation.html) on your local computer and verify that it works
    - ansible --version
    - note: on MacOS Ansible might not be added to your PATH in bash_profile, see [2nd answer in this thread](https://stackoverflow.com/questions/35898734/pip-installs-packages-successfully-but-executables-not-found-from-command-line/35899029) on how to fixed that.
1. [Initialize a memory card](https://www.raspberrypi.org/documentation/installation/installing-images/) (on your local computer) with the latest [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/) with [Etcher](https://www.balena.io/etcher/) or from the command line:
    - `diskutil list`
    - `diskutil unmountDisk /dev/<disk#>`
    - `sudo dd bs=1m if=<your image file>.img of=/dev/<disk#>`
1. [Enable ssh](https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/) for Raspbian headless operation (while memory card is still attached to your local computer)
    - `touch /Volumes/boot/ssh`
1. Insert the memory card in the to-be-provisioned Raspberry Pi and connect the it to the local network.
1. Clone this git repository on your local computer (if you haven't already done so)
    - 'git clone https://github.com/tkurki/marinepi-provisioning.git '
    - 'cd marinepi-provisioning'
1. Run either `./firstrun.sh` (uses hostname `raspberrypi.local`) or `./firstrun.sh <ip-of-your-raspi>` ([find out the IP address](https://www.raspberrypi.org/documentation/remote-access/ip-address.md)) to copy over your [ssh key](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md) & do the initial setup (change password for user `pi`, copy the ssh key, expand the filesystem)
    - note: MacOS users might see an error because 'sshpass' is not installed by default. See [answer in this thread](https://stackoverflow.com/questions/32255660/how-to-install-sshpass-on-mac) on how to install sshpass (first install XCode and than the XCode command line utilities)
1. When it asks you for SSH password type in `raspberry` (default password for `pi` user) and hit return.
1. When asked for a new password what you enter will be the new password for the `pi` user on the device.
    - note: characters like '@' seem to crash the process, try others characters if the process fails.
1. Edit configuration in `example-boat.yml` to match your environment and fill in your hotspot details
1. Run `./provision.sh <ip-of-your-raspi> example-boat.yml` to provision the software & configurations for the roles in example-boat.yml.
    - note: When you see an error like below, this is because the Pi is being rebooted. When the Pi comes back online, restart the provisioning process and it will continue.
    `RUNNING HANDLER [reboot] ****
    fatal: [192.168.x.x]: UNREACHABLE! =>`
    - note: Also just restart the process if your receive this error
    RUNNING HANDLER [nat_router : restart_hostapd] ***
    fatal: [192.168.x.x]: FAILED! => {"changed": false, "msg": "Unable to start service hostapd: Failed to start hostapd.service: Unit hostapd.service is masked
    - note: you might also see an error on installing pysk, see issues on github repo for a solution


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
