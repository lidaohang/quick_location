#bin/bash

path=ngx_on_memory

mkdir $path
export PATH=$PWD/stapxx/:$PATH

stapxx/samples/sample-bt-leaks.sxx -x $1 --arg time=10 -D STP_NO_OVERLOAD -D MAXMAPENTRIES=20000 > $path/$1.bt

#c++filt
cat $path/$1.bt | c++filt -n > $path/$1_new.bt

FlameGraph/stackcollapse-stap.pl $path/$1_new.bt > $path/$1.cbt
FlameGraph/flamegraph.pl --countname=bytes --title="Memory Leak Flame Graph" $path/$1.cbt > $path/$1.svg
