# hashicorp-installer
This is a simple script to install all Hashicorp products like Terraform, Vault, etc. on Linux systems. It supports Debian and Red Hat based distributions.

The script will set up the official Hashicorp repository on your system and list the available packages. You can install multiple packages at once

## Supported Distributions

| Distro |Versions |
|:----|:----|
|Ubuntu|Xenial, Bionic, Focal, Groovy, Hirsute, |Impish, Jammy, Kinetic|
|Debian|Jessie, Stretch, Buster, Bullseye, Bookworm|
|Fedora|33, 34, 35, 36, 37, 38|
|RHEL/CentOS|7, 8, 9|
|AmazonLinux|2, latest|

## usage 

```bash
sudo hashicorp-installer.sh
```
