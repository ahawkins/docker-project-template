#!/usr/bin/env bash
set -eou pipefail

curl -sSL https://get.docker.io/ubuntu/ | sudo sh

# Allow vagrant to run docker without sudo
sudo usermod -a -G docker vagrant
