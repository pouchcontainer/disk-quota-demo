#!/usr/bin/env bash
#
# setup fstab

set -euo pipefail

readonly pouch_root_path="/var/lib/pouch"

# update_fstab setups the extra disk.
update_fstab() {
  local inserted
  set +e; inserted=$(cat /etc/fstab | grep /dev/sdb || echo nothing); set -e

  if [[ "${inserted}" == "nothing" ]]; then
    sudo echo "/dev/sdb ${pouch_root_path} ext4 defaults 0 0" >> /etc/fstab
  fi
}

main() {
  # make ext4 fs for extra disk
  sudo mkfs.ext4 -O project,quota /dev/sdb

  # by default, pouchcontainer data is in /var/lib/pouch
  sudo mkdir -p ${pouch_root_path}
  sudo mount /dev/sdb ${pouch_root_path}

  update_fstab
}

main
