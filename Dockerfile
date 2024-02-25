# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install minimal necessary packages for SANE
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bc \
    ghostscript \
    imagemagick \
    libsane-common \
    netpbm \
    parallel \
    poppler-utils \
    sane \
    sane-utils \
    tesseract-ocr \
    tesseract-ocr-deu \
    tesseract-ocr-eng \
    units \
    unpaper \
    usbutils \
    vim-nox \
    && rm -rf /var/lib/apt/lists/*

# Install the SANE backend for the SP-1120N scanner
COPY ./pfusp-ubuntu_2.2.1_amd64.deb /tmp/pfusp-ubuntu_2.2.1_amd64.deb
RUN dpkg -i /tmp/pfusp-ubuntu_2.2.1_amd64.deb

# Fetch sane-scan-pdf and extract it
ADD https://github.com/rocketraman/sane-scan-pdf/archive/refs/heads/master.tar.gz /tmp/sane-scan-pdf.tar.gz
RUN tar -xvf /tmp/sane-scan-pdf.tar.gz -C /


# Set the entrypoint to the `scan` script
ENTRYPOINT ["/sane-scan-pdf-master/scan"]

# Set a default command or entrypoint (optional)
CMD ["--option-group", "default"]
