#!/bin/bash

set -eo pipefail

# Check the subscription status and register if necessary
if ! sudo subscription-manager status >& /dev/null ; then
   sudo subscription-manager register
fi

sudo dnf update -y
sudo dnf install -y kernel-devel
sudo dnf clean all -y
# sudo systemctl enable --now cockpit.socket

echo ""
echo "Package kernel-devel-$(uname -r) installed successfully. This is required to run Kepler."
echo "Done"
