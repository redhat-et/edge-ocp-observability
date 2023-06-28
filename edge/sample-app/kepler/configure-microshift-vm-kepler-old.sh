#!/bin/bash
#
# This script automates the VM configuration steps described in the "MicroShift Development Environment on RHEL 8" document.
# See https://github.com/openshift/microshift/blob/main/docs/devenv_rhel8_auto.md and 
# https://github.com/openshift/microshift/blob/main/docs/devenv_rhel8.md
#
set -eo pipefail

function usage() {
    echo "Usage: $(basename $0) <openshift-pull-secret-file>"
    [ ! -z "$1" ] && echo -e "\nERROR: $1"
    exit 1
}

if [ $# -ne 1 ]; then
    usage "Wrong number of arguments"
fi

OCP_PULL_SECRET=$(realpath $1)
[ ! -f "${OCP_PULL_SECRET}" ] && usage "OpenShift pull secret ${OCP_PULL_SECRET} does not exist or is not a regular file."

if [ "$(whoami)" != "redhat" ] ; then
    echo "This script should be run from 'redhat' user account"
    exit 1
fi

# Check the subscription status and register if necessary
if ! sudo subscription-manager status >& /dev/null ; then
   sudo subscription-manager register
fi

sudo dnf update -y
sudo dnf install -y kernel-devel
sudo dnf clean all -y
# sudo systemctl enable --now cockpit.socket

sudo cp -f ${OCP_PULL_SECRET} /etc/crio/openshift-pull-secret
sudo chmod 600                /etc/crio/openshift-pull-secret

# enable cgroupsv2
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1"

echo ""
echo "Kepler must run with cgroups-v2 when running in a virtual machine. Roboot machine before starting MicroShift."
echo "Done"
