#!/bin/sh
#
# The MIT License (MIT)
#
# Copyright (c) 2018 Thomas "Ventto" Venriès <thomas.venries@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

prev_stat="$(grep -E 'cpu[0-9]+' /proc/stat)"
sleep 1
curr_stat="$(grep -E 'cpu[0-9]+' /proc/stat)"
cpus_n="$(echo "$(grep -c processor /proc/cpuinfo) - 1" | bc)"

for i in $(seq 0 "$cpus_n"); do
    echo "$prev_stat" | grep -E "^cpu${i}" |
    while read -r cpu user nice sys idle iowait irq softirq steal o o; do
        previdle=$((idle + iowait))
        prevnoidle=$((user + nice + sys + irq + softirq + steal))
        echo "$curr_stat" | grep -E "^cpu${i}" |
        while read -r cpu user nice sys idle iowait irq softirq steal o o; do
            currtotal=$((idle + iowait + user + nice + sys + irq + softirq + steal))
            total=$((currtotal - (previdle + prevnoidle)))
            idle=$((idle + iowait - previdle))
            printf 'cpu%d: %.2f%%\n' "$i" \
                   "$(echo "(${total}-${idle})/${total}*100" | bc -l)"
        done
    done
done
