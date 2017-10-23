#bin/bash

path=ngx_on_cpu_u

mkdir $path

openresty-systemtap-toolkit/sample-bt -p $1 -t 5 -u > $path/$1.bt

#c++filt
cat $path/$1.bt | c++filt -n > $path/$1_new.bt

FlameGraph/stackcollapse-stap.pl $path/$1_new.bt > $path/$1.cbt
FlameGraph/flamegraph.pl  --title="On CPU Leak Flame Graph"  $path/$1.cbt > $path/$1.svg
