#!/bin/bash

set -e

ip=192.168.1.100
export https_proxy=http://$ip:7890
export http_proxy=http://$ip:7890
export all_proxy=socks5://$ip:7890
export no_proxy=localhost,127.0.0.1,.example.com,sh.rustup.rs,apt-mirror.front.sepia.ceph.com

tee ~/.bashrc <<-'EOF'
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

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

# enable gcc 11
# source /opt/rh/gcc-toolset-11/enable

EOF

# update yum source
cd /etc && \
  mv yum.repos.d yum.repos.d.bak && \
  mkdir yum.repos.d && \
  cd /tmp || exit

tee /etc/yum.repos.d/CentOS-Linux-AppStream.repo <<-'EOF'
# CentOS-Linux-AppStream.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[appstream]
name=CentOS Linux $releasever - AppStream
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=AppStream&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/AppStream/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-BaseOS.repo <<-'EOF'
# CentOS-Linux-BaseOS.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[baseos]
name=CentOS Linux $releasever - BaseOS
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=BaseOS&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-ContinuousRelease.repo <<-'EOF'
# CentOS-Linux-ContinuousRelease.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.
#
# The Continuous Release (CR) repository contains packages for the next minor
# release of CentOS Linux.  This repository only has content in the time period
# between an upstream release and the official CentOS Linux release.  These
# packages have not been fully tested yet and should be considered beta
# quality.  They are made available for people willing to test and provide
# feedback for the next release.

[cr]
name=CentOS Linux $releasever - ContinuousRelease
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=cr&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/cr/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-Debuginfo.repo <<-'EOF'
# CentOS-Linux-Debuginfo.repo
#
# All debug packages are merged into a single repo, split by basearch, and are
# not signed.

[debuginfo]
name=CentOS Linux $releasever - Debuginfo
baseurl=http://debuginfo.centos.org/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-Devel.repo <<-'EOF'
# CentOS-Linux-Devel.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[devel]
name=CentOS Linux $releasever - Devel WARNING! FOR BUILDROOT USE ONLY!
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=Devel&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/Devel/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-Extras.repo <<-'EOF'
# CentOS-Linux-Extras.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[extras]
name=CentOS Linux $releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/extras/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-FastTrack.repo <<-'EOF'
# CentOS-Linux-FastTrack.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[fasttrack]
name=CentOS Linux $releasever - FastTrack
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=fasttrack&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/fasttrack/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-HighAvailability.repo <<-'EOF'
# CentOS-Linux-HighAvailability.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[ha]
name=CentOS Linux $releasever - HighAvailability
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=HighAvailability&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/HighAvailability/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-Media.repo <<-'EOF'
# CentOS-Linux-Media.repo
#
# You can use this repo to install items directly off the installation media.
# Verify your mount point matches one of the below file:// paths.

[media-baseos]
name=CentOS Linux $releasever - Media - BaseOS
baseurl=file:///media/CentOS/BaseOS
        file:///media/cdrom/BaseOS
        file:///media/cdrecorder/BaseOS
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[media-appstream]
name=CentOS Linux $releasever - Media - AppStream
baseurl=file:///media/CentOS/AppStream
        file:///media/cdrom/AppStream
        file:///media/cdrecorder/AppStream
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-Plus.repo <<-'EOF'
# CentOS-Linux-Plus.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[plus]
name=CentOS Linux $releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/centosplus/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-PowerTools.repo <<-'EOF'
# CentOS-Linux-PowerTools.repo
#
# The mirrorlist system uses the connecting IP address of the client and the
# update status of each mirror to pick current mirrors that are geographically
# close to the client.  You should use this for CentOS updates unless you are
# manually picking other mirrors.
#
# If the mirrorlist does not work for you, you can try the commented out
# baseurl line instead.

[powertools]
name=CentOS Linux $releasever - PowerTools
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=PowerTools&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111/PowerTools/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/yum.repos.d/CentOS-Linux-Sources.repo <<-'EOF'
# CentOS-Linux-Sources.repo

[baseos-source]
name=CentOS Linux $releasever - BaseOS - Source
baseurl=http://vault.centos.org/$contentdir/$releasever/BaseOS/Source/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[appstream-source]
name=CentOS Linux $releasever - AppStream - Source
baseurl=http://vault.centos.org/$contentdir/$releasever/AppStream/Source/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[powertools-source]
name=CentOS Linux $releasever - PowerTools - Source
baseurl=http://vault.centos.org/$contentdir/$releasever/PowerTools/Source/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[extras-source]
name=CentOS Linux $releasever - Extras - Source
baseurl=http://vault.centos.org/$contentdir/$releasever/extras/Source/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[plus-source]
name=CentOS Linux $releasever - Plus - Source
baseurl=http://vault.centos.org/$contentdir/$releasever/centosplus/Source/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

EOF

tee /etc/ld.so.conf.d/usr-local-lib.conf <<-'EOF'
/usr/local/lib

EOF

yum clean all && yum makecache

# install tools
yum install -y epel-release && \
  yum install -y scl-utils dnf yum-utils && \
  dnf update -y epel-release && \
  yum makecache

dnf config-manager --add-repo http://apt-mirror.front.sepia.ceph.com/lab-extras/8/ && \
  dnf config-manager --setopt=apt-mirror.front.sepia.ceph.com_lab-extras_8_.gpgcheck=0 --save && \
  dnf -y module enable javapackages-tools

printf "Asia\nShanghai" | yum install -y tzdata
yum groupinstall -y 'Development Tools'
yum install -y vim git curl wget net-tools autoconf automake \
  binutils binutils-devel make cmake gcc gcc-c++ \
  gcc-toolset-11* ninja-build python3 python3-devel \
  smartmontools sysstat util-linux perf python3-sphinx python3-pip libtool \
  golang nodejs ack fontconfig npm llvm clang ccache \
  debbuild libzstd-devel tcl java-1.8.0-openjdk-headless \
  elfutils-devel elfutils-libelf elfutils-libelf-devel elfutils-libs \
  openssl-devel bzip2-devel libffi-devel ncurses ncurses-devel \
  ctags tcl-devel ruby ruby-devel lua lua-devel lua-libs luajit luajit-devel \
  perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-Install \
  perl-ExtUtils-CBuilder perl-ExtUtils-Embed numactl-devel numactl-libs \
  sqlite sqlite-devel readline gpm-devel thrift-devel texinfo \
  rdma-core-devel systemd-devel libblkid-devel openldap-devel \
  libaio libaio-devel snappy-devel gperftools gperftools-devel curl-devel \
  help2man libunwind-devel lttng-ust-devel libcap-ng-devel fuse-devel \
  asciidoc xmlto docbook2X which openssl expat-devel jq time \
  libzbd-devel libzbd clang-tools-extra ca-certificates doxygen \
  e2fsprogs e2fsprogs-libs nvme-cli fio libss re2 \
  java java-17-openjdk java-17-openjdk-devel \
  python38 python38-devel bc psmisc

echo 2 | update-alternatives --config python3 && \
  pip3 install --upgrade pip

# shellcheck source=/dev/null
# source /opt/rh/gcc-toolset-11/enable

curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  /bin/bash -c '$HOME/.cargo/bin/rustup component add rust-src rust-analyzer-preview'

# shellcheck source=/dev/null
source "$HOME/.cargo/env"

# upgrade llvm
#RUN wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-16.0.6.tar.gz && \
#  tar -zxf llvmorg-16.0.6.tar.gz && \
#  cd llvm-project-llvmorg-16.0.6 && \
#  mkdir build && \
#  cd build && \
#  cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt" -G "Unix Makefiles" ../llvm && \
#  make -j4 && \
#  make install && \
#  cd ../.. && \
#  rm -rf llvm-project-llvmorg-16.0.6 llvmorg-16.0.6.tar.gz

# install vim 9
# RUN wget -O vim-v9.1.0042.tar.gz https://github.com/vim/vim/archive/refs/tags/v9.1.0042.tar.gz && \
#   tar -zxf vim-v9.1.0042.tar.gz && \
#   cd vim-9.1.0042 && \
#   ./configure --with-features=huge --enable-multibyte --enable-gtk3-check --enable-rubyinterp=yes --enable-pythoninterp=yes --with-python3-command=python3.8 --enable-python3interp=yes --enable-cscope --enable-fontset --enable-largefile --prefix=/usr/local && \
#   make && \
#   make install && \
#   cd .. && \
#   rm -rf vim-v9.1.0042.tar.gz vim-9.1.0042

# install vimrc
# RUN ln -s /usr/lib64/libclang.so.12 /usr/lib64/libclang.so && \
#   git clone --depth=1 https://github.com/jrchyang/vimrc.git ~/.vim_runtime && \
#   cd ~/.vim_runtime && \
#   git submodule update --init --recursive && \
#   python3 ~/.vim_runtime/my_plugins/YouCompleteMe/install.py --clang-completer --clangd-completer --system-libclang --cs-completer --ts-completer --force-sudo && \
#   /bin/bash -c '$HOME/.vim_runtime/install_awesome_vimrc.sh' && \
#   cd -
git clone --depth=1 https://github.com/jrchyang/vimrc.git ~/.vim_runtime && \
  cd ~/.vim_runtime && \
  /bin/bash -c '$HOME/.vim_runtime/install_awesome_vimrc.sh' && \
  cd - || exit

# install exa
wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip && \
  unzip exa-linux-x86_64-v0.10.1.zip -d exa-linux-x86_64-v0.10.1 && \
  mv exa-linux-x86_64-v0.10.1 /usr/local/bin/ && \
  ln -s /usr/local/bin/exa-linux-x86_64-v0.10.1/bin/exa /usr/local/bin/exa && \
  rm -rf exa-linux-x86_64-v0.10.1.zip

# install powerline font
git clone --depth=1 https://github.com/powerline/fonts.git && \
  /bin/bash -c 'fonts/install.sh' && \
  rm -rf fonts

# install liburing
wget https://github.com/axboe/liburing/archive/refs/tags/liburing-0.7.tar.gz && \
  tar -zxf liburing-0.7.tar.gz && \
  cd liburing-liburing-0.7 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf liburing-0.7.tar.gz liburing-liburing-0.7

# install boost
wget https://boostorg.jfrog.io/artifactory/main/release/1.75.0/source/boost_1_75_0.tar.gz && \
  tar -zxf boost_1_75_0.tar.gz && \
  cd boost_1_75_0 && \
  ./bootstrap.sh && \
  sed -i '/project : default-build <toolset>gcc ;/a\\nusing python : 3.6 : /usr/bin/python3.6 : /usr/include/python3.6m : /usr/lib64/libpython3.6m.so ;' project-config.jam && \
  ./b2 && \
  ./b2 install && \
  cd .. && \
  rm -rf boost_1_75_0*

# install lz4
wget -O lz4-v1.9.3.tar.gz https://github.com/lz4/lz4/archive/refs/tags/v1.9.3.tar.gz && \
  tar -zxf lz4-v1.9.3.tar.gz && \
  cd lz4-1.9.3 && \
  make && \
  make install && \
  cd .. && \
  rm -rf lz4-1.9.3 lz4-v1.9.3.tar.gz

# install clickhouse
wget -O abseil-cpp-20200923.3.tar.gz https://github.com/abseil/abseil-cpp/archive/refs/tags/20200923.3.tar.gz && \
  tar -zxf abseil-cpp-20200923.3.tar.gz && \
  cd abseil-cpp-20200923.3 && \
  mkdir build && \
  cd build && \
  cmake .. -DCMAKE_BUILD_TYPE=Debug && \
  make && \
  make install && \
  cd ../.. && \
  rm -rf abseil-cpp-20200923.3*

wget -O clickhouse-cpp-v2.1.0.tar.gz https://github.com/ClickHouse/clickhouse-cpp/archive/refs/tags/v2.1.0.tar.gz && \
  tar -zxf clickhouse-cpp-v2.1.0.tar.gz && \
  cd clickhouse-cpp-2.1.0 && \
  mkdir build && \
  cd build && \
  cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug && \
  make && \
  make install && \
  cd ../.. && \
  rm -rf clickhouse-cpp*

# install rocksdb deps
git clone --depth=1 --branch v2.2.2 https://github.com/gflags/gflags.git gflags-v2.2.2 && \
  cd gflags-v2.2.2 && \
  mkdir build && \
  cd build && \
  cmake .. -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Debug && \
  make && \
  make install && \
  cd ../.. && \
  rm -rf gflags-v2.2.2

git clone --depth=1 --branch 1.1.10 https://github.com/google/snappy.git snappy-v1.1.10 && \
  cd snappy-v1.1.10 && \
  git submodule update --init --recursive && \
  mkdir build && \
  cd build && \
  cmake .. -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Debug && \
  make && \
  make install && \
  cd ../..  && \
  rm -rf snappy-v1.1.10

# install rocksdb 7.9.2
git clone --depth=1 --branch v7.9.2 https://github.com/facebook/rocksdb.git rocksdb-v7.9.2 && \
  cd rocksdb-v7.9.2 && \
  mkdir build && \
  cd build && \
  cmake .. -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DFAIL_ON_WARNINGS=OFF -DWITH_ZLIB=1 -DWITH_ZSTD=1 -DCMAKE_BUILD_TYPE=Debug -DUSE_RTTI=1 && \
  ninja -j`nproc` && \
  ninja install && \
  cd ../.. && \
  rm -rf rocksdb-v7.9.2

# get ceph to install dep
git clone --depth=1 --branch v17.2.7 https://github.com/ceph/ceph ceph-v17.2.7 && \
  cd ceph-v17.2.7 && \
  /bin/bash -c './install-deps.sh' && \
  cd .. && \
  rm -rf ceph-v17.2.7

git clone --depth=1 --branch v18.2.1 https://github.com/ceph/ceph ceph-v18.2.1 && \
  cd ceph-v18.2.1 && \
  /bin/bash -c './install-deps.sh' && \
  cd .. && \
  rm -rf ceph-v18.2.1

which gcc
which cargo
ls /usr/local/lib

yum clean all
