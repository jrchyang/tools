#!/bin/bash

set -e

function check_parameter()
{
  if [ -z "$fstype" ];then
    echo "please input fs type you want use"
    exit
  fi

  if [ "$fstype" != "ext4" ] && [ "$fstype" != "xfs" ];then
    echo "for now we only support ext4 and xfs, do not support $fstype"
    exit
  fi

  if [ -z "$bdev" ];then
    echo "please input block device you want use"
    exit
  fi

  if [ ! -b "/dev/$bdev" ];then
    echo "the input /dev/$bdev is not a block device"
    exit
  fi

  if [ -z "$tdir" ];then
    echo "please input dir you want use"
    exit
  fi

  if [ ! -d "$tdir" ];then
    echo "the input $tdir is not a dir"
    exit
  fi
}

function check_mounted()
{
  if df | grep "$bdev" &>/dev/null;then
    echo "$bdev aleardy mounted"
    exit
  fi

  if df | grep "$tdir" &>/dev/null;then
    echo "$tdir aleardy mounted"
    exit
  fi
}

function setup_ext4()
{
  local bdev_path="/dev/$bdev"

  dd if=/dev/zero of="$bdev_path" bs=4M count=1 oflag=direct
  if mkfs.ext4 "$bdev_path";then
    echo "failed to make ext4 on $bdev_path"
    exit
  fi

  if mount -o defaults,nodelalloc,noatime -o data=ordered "$bdev_path" "$tdir";then
    echo "failed to mount $tdir"
    exit
  fi
}

function setup_xfs()
{
  local bdev_path="/dev/$bdev"
  local block_size=0

  dd if=/dev/zero of="$bdev_path" bs=4M count=1 oflag=direct
  block_size=$(cat /sys/block/"$bdev"/queue/logical_block_size)
  if [ "$block_size" -lt 1024 ];then
    block_size=1024
  fi

  if mkfs.xfs -f -b size="$block_size" -m crc=0,finobt=0 "$bdev" -K;then
    echo "failed to make xfs on $bdev"
    exit
  fi

  if mount -o noatime,discard "$bdev" "$tdir";then
    echo "failed to mount $tdir"
    exit
  fi
}

fstype=""
bdev=""
tdir=""

GETOPT_ARGS=$(getopt -q -o t:b:d: --long type:blockdevice:dir:,not_success -- "$@")
eval set -- "$GETOPT_ARGS"

#获取参数
while [ -n "$1" ]
do
  case "$1" in
    -t|--type) fstype=$2; shift 2;;
    -b|--blockdevice) bdev=$2; shift 2;;
    -d|--dir) tdir=$2; shift 2;;
    --) shift; break;;
    *) echo "unimplemented option"; exit 1;;
  esac
done

check_parameter
check_mounted

if [ "$fstype" == "ext4" ];then
  setup_ext4
elif [ "$fstype" == "xfs" ];then
  setup_xfs
fi
