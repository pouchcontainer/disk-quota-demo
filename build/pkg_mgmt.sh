#!/usr/bin/env bash
#
# ubuntu package management

set -euo pipefail

# all commands are running without interactive
#
# fix "dpkg-reconfigure: unable to re-open stdin: No file or directory" error
export DEBIAN_FRONTEND=noninteractive

# setup_mirror_source uses mirror package source instead of default value.
#
# NOTE: use mirror.tuna.tsinghua.edu.cn 18.04 LTS because of GFW.
setup_mirror_source() {
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.old

  cat <<-EOF | sudo tee /etc/apt/sources.list
# mirror tsinghua.edu.cn
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
EOF

  sudo apt-get update -y
}

# setup_pouch_source adds aliyun pouchcontainer source
setup_pouch_source() {
  curl -fsSL http://mirrors.aliyun.com/opsx/pouch/linux/debian/opsx@service.alibaba.com.gpg.key | sudo apt-key add -

  sudo add-apt-repository "deb http://mirrors.aliyun.com/opsx/pouch/linux/debian/ pouch stable"
}

main() {
  setup_mirror_source
  setup_pouch_source
}

main
