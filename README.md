SP-1120N Scanner Docker Setup
=============================

In 2023, I acquired a Ricoh (Fujitsu) SP-1120N scanner, which performed well with a Windows 10 PC. However, integrating it with NixOS presented challenges (the non-free SANE backend was not yet packaged). Facing urgent document scanning needs and aiming for a straightforward solution, I chose Docker to bridge the compatibility gap. This repository documents the process of packaging the necessary drivers within a Docker image to facilitate scanner usage across different systems.

## Prerequisites
- Docker installed on your system.
- Basic familiarity with Docker commands and concepts.
- The `pfusp-ubuntu_2.2.1_amd64.deb` driver file, downloadable below.

## Driver Download
The official Ubuntu 22.04 drivers for the SP-1120N scanner are available on the [Ricoh website](https://www.pfu.ricoh.com/global/scanners/fi/dl/ubuntu22-sp-11xxn.html). For convenience, a copy of the driver file, `pfusp-ubuntu_2.2.1_amd64.deb`, is also archived on the [Wayback Machine](http://web.archive.org/web/20240225130143/https://origin.pfultd.com/downloads/IMAGE/driver/ubuntu/221/pfusp-ubuntu_2.2.1_amd64.deb).

## Building the Docker Image
1. Download the `pfusp-ubuntu_2.2.1_amd64.deb` file to the same directory as your Dockerfile.
2. Build the Docker image using the command:
   ```bash
   docker build -t sp-1120n-scanner .
   ```

## Using the Container
The image leverages the [SANE Command-Line Scan to PDF](https://github.com/rocketraman/sane-scan-pdf) script by [Raman Gupta](https://github.com/rocketraman) for straightforward scanning operations. By default, the script uses "option groups" from `/root/.local/share/sane-scan-pdf/defaults`. To apply your configurations, mount the `profiles` directory accordingly inside the container, as demonstrated below.

Directly passing parameters to the container bypasses the default profile, necessitating manual input of all necessary parameters!

### Examples
The examples assume that they are being executed from the root of this repository.

- **Using Default Settings:**

  This uses the included default settings for scanning and saves the output in the mounted `output` directory.
  ```bash
  docker run --privileged --rm -it -v $(pwd)/output:/output -v $(pwd)/profiles:/root/.local/share/sane-scan-pdf sp-1120n-scanner
  ```
- **Specifying an Option Group:**

  Replace `EXAMPLE` with the name of your custom option group defined within the `profiles` directory for tailored scanning settings.
  ```bash
  docker run --privileged --rm -it -v $(pwd)/output:/output -v $(pwd)/profiles:/root/.local/share/sane-scan-pdf sp-1120n-scanner --option-group EXAMPLE
  ```
- **Dynamic Output Filename:**

  Utilizes the default profile while naming the output file with the current date and time, ensuring each scan is uniquely identified.
  ```bash
  docker run --privileged --rm -it -v $(pwd)/output:/output -v $(pwd)/profiles:/root/.local/share/sane-scan-pdf sp-1120n-scanner --option-group default --output /output/$(date +%Y-%m-%d_%H-%M-%S).pdf
  ```

### Default Option Group
The repository features pre-configured option groups tailored to specific scanning requirements. The default option group, automatically applied in the absence of explicit parameters, is outlined in the `profiles/default` file. Its configurations are as follows:

* Device: `pfusp`
* Output: `/output/<date+time (UTC)>.pdf` (inside the container)
* Mode: `Gray`
* Resolution: `300`
* Paper Size: `A4`
* Duplex: `yes`
* Skip Blank Pages: `yes`
* OCR: `yes`
* OCR Language: `deu` (German)
* Skip empty pages: `yes`
* White detection threshold: `99%`

These settings ensure a versatile scanning setup, capable of handling various document types efficiently, with the added benefits of OCR optimized for German language and intelligent blank page skipping for streamlined document processing.

Note that the skipping of empty pages is not as reliable as one might expect.

## Debugging / Testing
To verify scanner recognition within the Docker container, execute the command below:
```bash
docker run --rm -it --privileged --entrypoint=/bin/sh sp-1120n-scanner -c 'scanimage -L'
```
Successful detection will yield output akin to:
```
$ docker run --rm -it --privileged --entrypoint=/bin/sh sp-1120n-scanner -c 'scanimage -L'
Created directory: /var/lib/snmp/cert_indexes
device `pfusp:SP1120N:004:002' is a  SP1120N scanner
```
This indicates the scanner is properly identified within the container, with a device entry showing `pfusp` as the device type and including the scanner's name/model number.

### Manual Test Scanning
For hands-on testing and custom configuration, initiate the container in interactive mode with shell access to manually run `sane-scan-pdf`.
```bash
docker run --rm -it --privileged --entrypoint=/bin/bash sp-1120n-scanner
```
Once inside the container's shell, you have the flexibility to manually execute the `scan` script and explore its options. For instance, to view the available command-line options:
```bash
/sane-scan-pdf-master/scan --help
```
