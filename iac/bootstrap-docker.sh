#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y \
    py-pip \
    python3-dev \
    libffi-dev \
    openssl-dev \
    gcc \
    libc-dev \
    rust \
    cargo \
    git \
    make 

# Initialize git
git init && \
    git config --global user.email "notreal@teamcfe.com" && \
    git config --global user.name "Team CFE"

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# autoremove unused packages
sudo apt-get autoremove -y

