#bin/bash

path=ngx_on_cpu_lua

mkdir $path

openresty-systemtap-toolkit/ngx-sample-lua-bt -p $1 -t 5 --luajit20 -t 5 > $path/tmp.bt

openresty-systemtap-toolkit/fix-lua-bt $path/tmp.bt > $path/$1.bt


FlameGraph/stackcollapse-stap.pl $path/$1.bt > $path/$1.cbt
FlameGraph/flamegraph.pl  --title="On CPU Leak Flame Graph"  $path/$1.cbt > $path/$1.svg
