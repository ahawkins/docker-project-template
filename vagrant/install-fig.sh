#!/usr/bin/env bash
set -eou pipefail

sudo curl -L https://github.com/docker/fig/releases/download/1.0.0/fig-`uname -s`-`uname -m` > /usr/local/bin/fig
sudo chmod +x /usr/local/bin/fig
