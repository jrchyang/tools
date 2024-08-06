#!/bin/bash
set -e

function bluestore_config_on()
{
  local debug_level=$1

  ceph daemon osd.0 config set log_to_file 1
  ceph daemon osd.0 config set debug_bluestore "$debug_level"/"$debug_level"
  ceph daemon osd.0 config set debug_bluefs "$debug_level"/"$debug_level"
  ceph daemon osd.0 config set debug_bdev "$debug_level"/"$debug_level"
}

function bluestore_config_off()
{
  ceph daemon osd.0 config set log_to_file 0
  ceph daemon osd.0 config set debug_bluestore 0/0
  ceph daemon osd.0 config set debug_bluefs 0/0
  ceph daemon osd.0 config set debug_bdev 0/0
}

opt=$1
level=$2

if [ "$opt" == "bluestore-cfg-on" ];then
  bluestore_config_on "$level"
elif [ "$opt" == "bluestore-cfg-off" ];then
  bluestore_config_off
fi
