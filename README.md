SP-1120N Scanner Docker Setup
=============================

In 2023 I bought a Fujitsu SP-1120N scanner. While the device works as expected when connected to a Windows 10 PC, I
struggled to get it to work on my NixOS machine.
As I had some documents to scan and was unwilling to put in the time to repackage the Ubuntu 22.04 drivers for NixOS, I
decided to take the easy way out and use Docker to use the scanner for now.

The idea is to package everything needed to use the scanner in a Docker image and then run it in a container.
