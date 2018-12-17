#!/usr/bin/env bash
#
# ubuntu install tools

set -euo pipefail

# all commands are running without interactive
#
# fix "dpkg-reconfigure: unable to re-open stdin: No file or directory" error
export DEBIAN_FRONTEND=noninteractive

# install_base installs base tools.
install_base() {
  sudo apt-get install -y \
    wget \
    curl \
    unzip \
    zip \
    tree \
    tar \
    silversearcher-ag \
    jq \
    \
    zsh \
    vim \
    neovim \
    python3-pip \
    tmux \
    \
    git \
    gcc \
    cmake \
    make \
    \
    lsof
}

# install_golang install golang 
# NOTE: go source code and binary are at /usr/local/go. Need to setup the path.
install_golang() {
  local go_src target version latest_version

  # purge old src
  go_src="/usr/local/go"
  if [[ -d "${go_src}" ]]; then
    sudo rm -rf "${go_src}"
  fi

  latest_version="$(curl -sSL "https://golang.org/VERSION?m=text")"
  set +u; version="${GO_VESION:-${latest_version}}"; set -u
  target="https://redirector.gvt1.com/edgedl/go/${version}.linux-amd64.tar.gz"

  curl -sSL "${target}" | sudo tar -v -C /usr/local -xz
}

# install_quota_tools installs quota tools v4.0.4.
install_quota_tools() {
  local src_code target

  target="quota_4.04.orig.tar.gz"
  src_code="https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/quota"
  src_code="${src_code}/4.04-2ubuntu0.1/${target}"

  curl -sSL "${src_code}" | sudo tar -v -C /tmp/ -xz
  cd /tmp/quota-4.04
  ./configure
  make
  sudo make install

  cd - # back to last dir
}

# install_pouchcontainer installs pouchcontainer from aliyun source.
install_pouchcontainer() {
  sudo apt-get install -y pouch
}

main() {
  install_base
  install_golang
  install_quota_tools
  install_pouchcontainer
}

main
