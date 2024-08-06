#!/bin/bash

set -e

log_file=$1

awk '
BEGIN {
    lt4k = 0
    lt8k = 0 
    lt16k = 0
    lt32K = 0
    lt64k = 0
    lt128k = 0
    gt128k = 0
    prev_io_start = 0
    prev_io_len = 0
    cur_io_start = 0
    continuous_io_cnt = 0
    order_continuous_io_cnt = 0
    reverse_continuous_io_cnt = 0
    total_io_cnt = 0
}

$6 ~ /Q/ {
    size = $(NF-1) * 512
    if (size < 4096) {
        lt4k++
    } else if (size < 8192) {
        lt8k++ 
    } else if (size < 16384) {
        lt16k++
    } else if (size < 32768) {
        lt32k++
    } else if (size < 65536) {
        lt64k++
    } else if (size < 131072) {
        lt128k++
    } else {
        gt128k++
    }
    if (prev_io_len == 0) {
        prev_io_start = $(NF-3)
        prev_io_len = $(NF-2)
    } else {
        cur_io_start = $(NF-3)
        if (cur_io_start == (prev_io_start + prev_io_len)) {
            continuous_io_cnt++
        } else if (cur_io_start > (prev_io_start + prev_io_len)) {
            order_continuous_io_cnt++
        } else {
            reverse_continuous_io_cnt++
        }
        prev_io_start = $(NF-3)
        prev_io_len = $(NF-2)
    }
    total_io_cnt++
}

END {
    print "I/O 大小分布统计(仅包含 Q 字符的行):"
    printf "小于 4KB: %d 个, 占比 %d%%\n", lt4k, lt4k*100/total_io_cnt
    printf "小于 8KB: %d 个, 占比 %d%%\n", lt8k, lt8k*100/total_io_cnt
    printf "小于 16KB: %d 个, 占比 %d%%\n", lt16k, lt16k*100/total_io_cnt
    printf "小于 32KB: %d 个, 占比 %d%%\n", lt32k, lt32k*100/total_io_cnt
    printf "小于 64KB: %d 个, 占比 %d%%\n", lt64k, lt64k*100/total_io_cnt
    printf "小于 128KB: %d 个, 占比 %d%%\n", lt128k, lt128k*100/total_io_cnt
    printf "大于 128KB: %d 个, 占比 %d%%\n", gt128k, gt128k*100/total_io_cnt
    print "I/O 连续情况统计："
    printf "连续 IO %d 个, 占比 %d%%\n", continuous_io_cnt, continuous_io_cnt*100/total_io_cnt
    printf "顺序 IO %d 个, 占比 %d%%\n", order_continuous_io_cnt, order_continuous_io_cnt*100/total_io_cnt
    printf "逆序 IO %d 个, 占比 %d%%\n", reverse_continuous_io_cnt, reverse_continuous_io_cnt*100/total_io_cnt
}
' < "$log_file"
