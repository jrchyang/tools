#!/bin/bash

sudo apt-get update
sudo apt-get install -y ca-certificates

# update apt source
tee /etc/apt/sources.list <<-'EOF'
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse

EOF

# install tools
sudo apt-get update
sudo apt-get install -y \
  vim git wget curl net-tools apt-file libtool\
  gcc g++ make automake cmake ninja-build build-essential \
  python3 python3-dev python3-sphinx golang nodejs \
  ack fonts-powerline vim-nox mono-complete openjdk-17-jdk openjdk-17-jre \
  npm llvm clang clangd libnuma-dev libzstd-dev libzbd-dev bear ccache \
  lua5.4 liblua5.4-dev tcl sqlite3 libsqlite3-dev \
  systemtap-sdt-dev libbpfcc-dev libbpf-dev libclang-dev bison flex \
  libelf-dev libcereal-dev libgtest-dev libgmock-dev asciidoctor \
  libthrift-dev texinfo rdma-core libsystemd-dev libblkid-dev libaio-dev \
  libsnappy-dev lz4 tzdata exa bc dwarves jq libspdlog-dev \
  libprotobuf-dev protobuf-compiler zsh netcat libboost-all-dev \
  libclang-12-dev bpftrace librados-dev librbd-dev iputils-ping \
  nghttp2 libnghttp2-dev libssl-dev libcurl4-gnutls-dev \
  fakeroot dpkg-dev libcurl4-openssl-dev

sudo cp /sys/kernel/btf/vmlinux /usr/lib/modules/`uname -r`/build/

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

vim ~/.zshrc
:<<!
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

setopt rmstarsilent

alias rm='rm -rf'
alias ..='cd ..'
alias la='exa --long --header --group --modified --color-scale --all --sort=type'
alias ll='exa --long --header --group --modified --color-scale --sort=type'
alias ls='exa'
alias gs='git status'
alias gaa='git add .'
alias gcm='git commit -m'
alias gp='git push'

# set vim color
export TERM=xterm-256color

# ccache
export USE_CCACHE=1
export CCACHE_SLOPPINESS=file_macro,include_file_mtime,time_macros
export CCACHE_UMASK=002
!
source ~/.zshrc

# vim
git clone git@github.com:jrchyang/vimrc.git ~/.vim_runtime
# cd ~/.vim_runtime
# git submodule update --init --recursive
# python3 ~/.vim_runtime/my_plugins/YouCompleteMe/install.py --all --force-sudo
sh ~/.vim_runtime/install_awesome_vimrc.sh

# go
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get install -y golang
go env -w GOPROXY=https://goproxy.cn,direct

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
rustup component add rust-src rust-analyzer-preview

# install clickhouse
# vim ../absl/debugging/failure_signal_handler.cc
# size_t stack_size = (std::max<size_t>(SIGSTKSZ, 65536) + page_mask) & ~page_mask;
wget -O abseil-cpp-20200923.3.tar.gz https://github.com/abseil/abseil-cpp/archive/refs/tags/20200923.3.tar.gz && \
  tar -zxf abseil-cpp-20200923.3.tar.gz && \
  cd abseil-cpp-20200923.3 && \
  mkdir build && cd build && \
  cmake .. -DCMAKE_BUILD_TYPE=Release && \
  make && \
  sudo make install && \
  cd ../..

wget -O clickhouse-cpp-v2.1.0.tar.gz https://github.com/ClickHouse/clickhouse-cpp/archive/refs/tags/v2.1.0.tar.gz && \
  tar -zxf clickhouse-cpp-v2.1.0.tar.gz && \
  cd clickhouse-cpp-2.1.0 && \
  mkdir build && cd build && \
  cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release && \
  make && \
  sudo make install && \
  cd ../..

# install rocksdb deps
git clone --depth=1 --branch v2.2.2 https://github.com/gflags/gflags.git gflags-v2.2.2 && \
  cd gflags-v2.2.2 && \
  mkdir build && cd build && \
  cmake .. -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Release && \
  make && \
  sudo make install && \
  cd ../..

git clone --depth=1 --branch 1.1.10 https://github.com/google/snappy.git snappy-v1.1.10 && \
  cd snappy-v1.1.10 && \
  git submodule update --init --recursive && \
  mkdir build && cd build && \
  cmake .. -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Release && \
  make && \
  sudo make install && \
  cd ../..

wget -O leveldb-1.22.tar.gz https://github.com/google/leveldb/archive/refs/tags/1.22.tar.gz && \
  tar -zxf leveldb-1.22.tar.gz && \
  cd leveldb-1.22 && \
  mkdir build && cd build && \
  cmake .. -DCMAKE_BUILD_TYPE=Release && \
  make && \
  sudo make install && \
  cd ../..

git clone --depth=1 --branch fio-3.38 https://github.com/axboe/fio.git fio-v3.38  && \
  cd fio-v3.38 && \
  ./configure && \
  make && \
  cd ..

# ceph
git clone git@github.com:jrchyang/ceph.git && \
  cd ceph && \
  git checkout v17.2.7-learn && \
  git submodule update --init --recursive && \
  ./install-deps.sh
./do_cmake.sh -DCMAKE_CXX_STANDARD=20 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DWITH_CCACHE=ON -DWITH_MGR_DASHBOARD_FRONTEND=OFF -DWITH_SPDK=ON \
  -DWITH_ZBD=ON -DWITH_BLUESTORE=ON -DCMAKE_BUILD_TYPE=Release

# seastar
git clone git@github.com:jrchyang/seastar.git && \
  cd seastar && \
  git checkout v22.11.0-learn && \
  sudo ./install-dependencies.sh && \
  ./configure.py --mode=release --compile-commands-json --c++-standard=20
ninja -C build/release

# spdk
git clone git@github.com:jrchyang/spdk.git && \
  cd spdk && \
  git checkout v24.01-learn && \
  git submodule update --init --recursive
:<<!
diff --git a/scripts/pkgdep/common.sh b/scripts/pkgdep/common.sh
index 0f7151f..e35f632 100755
--- a/scripts/pkgdep/common.sh
+++ b/scripts/pkgdep/common.sh
@@ -252,6 +252,10 @@ pkgdep_toolpath() {
        chmod a+x "${export_file}"
 }

+export https_proxy=http://192.168.1.100:7890
+export http_proxy=http://192.168.1.100:7890
+export all_proxy=socks6://192.168.1.100:7890
+
 if [[ $INSTALL_DEV_TOOLS == true ]]; then
        install_shfmt
        install_spdk_bash_completion
!
sudo scripts/pkgdep.sh --all
./configure --with-fio=/home/jrchyang/install-srcs/fio-v3.38 --with-vhost \
  --with-vbdev-compress --with-crypto --with-virtio --with-vfio-user --with-rbd \
  --with-rdma --with-shared --with-iscsi-initiator --with-ocf --with-uring=/usr/lib64 \
  --with-raid5f --with-xnvme --with-fuse --with-usdt --enable-debug

# rocksdb
git clone git@github.com:jrchyang/rocksdb.git && \
  cd rocksdb && \
  git checkout v9.1.1-learn && \
  mkdir build && cd build
cmake .. -GNinja -DCMAKE_CXX_STANDARD=20 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DFAIL_ON_WARNINGS=OFF -DCMAKE_BUILD_TYPE=Release -DWITH_ZLIB=1 -DWITH_ZSTD=1 \
  -DUSE_RTTI=1 -DWITH_LZ4=ON

vim /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on iommu=pt"
sudo update-grub
sudo reboot
