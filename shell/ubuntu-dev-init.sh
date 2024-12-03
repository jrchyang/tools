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
  libelf-dev libcereal-dev libclang-dev libgtest-dev libgmock-dev asciidoctor \
  libthrift-dev texinfo rdma-core libsystemd-dev libblkid-dev libaio-dev \
  libsnappy-dev lz4 tzdata exa bc dwarves jq libspdlog-dev \
  libprotobuf-dev protobuf-compiler

# config bash
cp ~/.bashrc ~/.bashrc.bak
tee ~/.bashrc <<-'EOF'

# alias
alias rm='rm -rf'
alias ..='cd ..'
alias la='exa --long --header --group --modified --color-scale --all --sort=type'
alias ll='exa --long --header --group --modified --color-scale --sort=type'
alias ls='exa'
alias gs='git status'
alias gaa='git add .'
alias gcm='git commit -m'
alias gp='git push'

# set bash git branch
function git_branch {
    branch="`git branch 2>/dev/null | grep "^\*" | sed -e "s/^\*\ //"`"
    if [ "${branch}" != "" ];then
        if [ "${branch}" = "(no branch)" ];then
            branch="(`git rev-parse --short HEAD`...)"
        fi
        echo " ($branch)"
    fi
}
export PS1='\u@\h \[\033[01;36m\]\W\[\033[01;32m\]$(git_branch)\[\033[00m\] \$ '

# set vim color
export TERM=xterm-256color

# ccache
export USE_CCACHE=1
export CCACHE_SLOPPINESS=file_macro,include_file_mtime,time_macros
export CCACHE_UMASK=002

EOF

# install rust env
curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  /bin/bash -c '$HOME/.cargo/bin/rustup component add rust-src rust-analyzer-preview'

# install vim
git clone --depth=1 https://github.com/jrchyang/vimrc.git ~/.vim_runtime && \
  cd $HOME/.vim_runtime && \
  git submodule update --init --recursive && \
  python3 $HOME/.vim_runtime/my_plugins/YouCompleteMe/install.py --clang-completer --clangd-completer --system-libclang --cs-completer --go-completer --java-completer --ts-completer && \
  /bin/bash -c '$HOME/.vim_runtime/install_awesome_vimrc.sh'
  cd -

# install src
mkdir open-srcs && cd open-srcs

# get ceph to install dep
git clone --depth=1 --branch v17.2.7 https://github.com/ceph/ceph ceph-v17.2.7 && \
  cd ceph-v17.2.7 && \
  ./install-deps.sh && \
  cd -

git clone --depth=1 --branch v18.2.0 https://github.com/ceph/ceph ceph-v18.2.0 && \
  cd ceph-v18.2.0 && \
  ./install-deps.sh && \
  cd -

# install rocksdb deps
git clone --depth=1 --branch v2.2.2 https://github.com/gflags/gflags.git gflags-v2.2.2 && \
  cd gflags-v2.2.2 && \
  mkdir build && cd build && \
  cmake .. -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=RelWithDebug -DCMAKE_INSTALL_PREFIX=/usr && \
  make && \
  sudo make install && \
  cd ../..

git clone --depth=1 --branch 1.1.10 https://github.com/google/snappy.git snappy-v1.1.10 && \
  cd snappy-v1.1.10 && \
  git submodule update --init --recursive && \
  mkdir build && cd build && \
  cmake .. -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=RelWithDebug -DCMAKE_INSTALL_PREFIX=/usr && \
  make && \
  sudo make install && \
  cd ../..
