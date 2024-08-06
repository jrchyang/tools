#!/bin/bash
set -e

function get_config()
{
  ceph daemon osd.0 config get bluestore_hybrid_alloc_mem_cap 2>/dev/null
}

function reset_perf()
{
  ceph daemon osd.0 perf reset bluestore 2>/dev/null
}

function perf_dump()
{
  local msg=$1

  echo ""
  echo "perf dump $msg"
  date
  ceph -s 2>/dev/null
  ceph daemon osd.0 perf dump bluestore 2>/dev/null
  ceph daemon osd.0 bluestore allocator score block 2>/dev/null
  echo ""
}

function put_rgw_obj()
{
  for ((i=0;i<$((rgw_obj_num));++i)); do
    rados -p $pool_name put "$rgw_obj_name_prefix""$i" $rgw_obj_file 2>/dev/null
  done
}

function rm_rgw_obj()
{
  for ((i=0;i<$((rgw_obj_num));i+=2)); do
    rados -p $pool_name rm "$rgw_obj_name_prefix""$i" 2>/dev/null
  done
}

function put_rgw_ow_obj()
{
  for ((i=0;i<$((rgw_ow_obj_num));++i)); do
    rados -p $pool_name put "$rgw_ow_obj_name_prefix""$i" $rgw_obj_file 2>/dev/null
  done

  for ((i=0;i<$((rgw_ow_obj_num));++i)); do
    rados -p $pool_name put "$rgw_ow_obj_name_prefix""$i" $rgw_obj_file 2>/dev/null
  done
}

function rm_rgw_ow_obj()
{
  for ((i=0;i<$((rgw_ow_obj_num));i+=2)); do
    rados -p $pool_name rm "$rgw_ow_obj_name_prefix""$i" 2>/dev/null
  done
}

function put_fio_obj()
{
  for ((i=0;i<$((fio_obj_num));++i)); do
    rados -p $pool_name put "$fio_obj_name_prefix""$i" $fio_obj_file 2>/dev/null
  done
}

function rm_fio_obj()
{
  for ((i=0;i<$((fio_obj_num));++i)); do
    rados -p $pool_name rm "$fio_obj_name_prefix""$i" 2>/dev/null
  done
}

fio_obj_file=./obj_file_fio
rgw_obj_file=./obj_file_rgw
fio_obj_name_prefix="fio_obj_"
rgw_obj_name_prefix="rgw_obj_"
rgw_ow_obj_name_prefix="rgw_ow_obj_"
pool_name=test-pool-0
fio_obj_num=15000 # avl mem limit is 1M
rgw_obj_num=100000
rgw_ow_obj_num=10000

get_config
reset_perf
perf_dump "before put"

put_rgw_obj &
put_rgw_ow_obj &
put_fio_obj &
wait

perf_dump "after put"

rm_rgw_obj &
rm_rgw_ow_obj &
rm_fio_obj &
wait

perf_dump "after rm"
