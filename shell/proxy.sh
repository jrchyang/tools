#!/bin/bash

function usage()
{
  echo "$0 unset"
  echo "$0 set \$ip"
  exit
}

function set_proxy()
{
  if [ -z "$ip" ];then
    usage
  fi

  export https_proxy=http://$ip:7890
  export http_proxy=http://$ip:7890
  export all_proxy=socks5://$ip:7890
}

function unset_proxy()
{
  unset https_proxy
  unset http_proxy
  unset all_proxy
}

op=$1
ip=$2

if [ "$op" = "set" ];then
  set_proxy
elif [ "$op" = "unset" ];then
  unset_proxy
else
  usage
fi
