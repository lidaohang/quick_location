
## 说明
有时候会遇到一些疑难杂症，并且监控插件并不能一眼立马发现问题的根源。这时候就需要登录服务器进一步深入分析问题的根源。
那么分析问题也是有一定的套路和规律的，并且有些问题涉及到的领域非常广，需要有一定的技术经验的积累才能定位到问题。
那么如果我们有一套好的分析问题的方法及步骤，在加上强大的分析工具，那将是事半功倍，帮助大家快速定位问题，节省大家很多时间做更深入的事情。


## 背景
本篇文章主要介绍如何去定位问题，并且会结合案例去分析问题。对于文章中所提到的工具不做详细介绍，如果想了解更多更细的信息，请自行google。


## 分析问题的方法论
套用5W2H方法，可以提出性能分析的几个问题
 - What-现象是什么样的
 - When-什么时候发生
 - Why-为什么会发生
 - Where-哪个地方发生的问题
 - How much-耗费了多少资源
 - How to do-怎么解决问题


## 分析问题的步骤
首先我们得通过相应的监控知道是什么问题，什么指标有波动或者异常，然后通过分析该指标逐步的去分析和定位问题的根源。


### cpu问题


#### 查看系统cpu使用情况
```
top

```

#### 查看所有cpu核信息
```
mpstat -P ALL 1
 
 
#说明：
%user 在internal时间段里，用户态的CPU时间(%)，不包含nice值为负进程 (usr/total)*100
%nice 在internal时间段里，nice值为负进程的CPU时间(%) (nice/total)*100
%sys 在internal时间段里，内核时间(%) (system/total)*100
%iowait 在internal时间段里，硬盘IO等待时间(%) (iowait/total)*100
%irq 在internal时间段里，硬中断时间(%) (irq/total)*100
%soft 在internal时间段里，软中断时间(%) (softirq/total)*100
%idle 在internal时间段里，CPU除去等待磁盘IO操作外的因为任何原因而空闲的时间闲置时间(%) (idle/total)*100

```


#### 进程cpu的统计信息
```
pidstat -u 1 -p pid
```


#### 函数级cpu使用情况

```
perf top -p pid
```

#### 函数级cpu过热详细信息

```
perf record -F 99 -p 13204 -g -- sleep 30
perf report -n --stdio

```




### 内存问题


#### 查看系统内存使用情况
```
free -m
```

#### 虚拟内存统计信息
```
vmstat 1

```

#### 进程级别内存情况
```
#1s采集周期，获取内存的统计信息
pidstat -p pid -r 1
```



## 磁盘问题
#### 查看系统级io信息
```
iotop
```

#### 统计io详细信息
```
iostat -d -x -k 1 10
```

#### 查看进程级io的信息
```
pidstat -d 1 -p  pid
```




## 连接问题
#### 查看连接数
```
ss -s 

#或者

netstat
```

#### tcp状态
```

sar -n TCP,ETCP 1
#说明：
#active/s 新的主动连接#passive/s 新的被动连接
#iseg/s 接受的段
#oseg/s 输出的段
```


## 网络问题
#### 查看网络IO
```
sar -n DEV 1

#说明：
IFACE 网络设备名
rxpck/s 每秒接收的包总数
txpck/s 每秒传输的包总数
rxbyt/s 每秒接收的字节（byte）总数
txbyt/s 每秒传输的字节（byte）总数
rxcmp/s 每秒接收压缩包的总数
txcmp/s 每秒传输压缩包的总数
rxmcst/s 每秒接收的多播（multicast）包的总数

```

#### 抓包
```
//tcpdump 是一个很方便的抓包工具，是以包为单位进行输出的，阅读起来不是很方便
tcpdump 
 

//tcpflow是面向tcp流的。 每个tcp传输会保存成一个文件,很方便的查看
tcpflow -i eth0
```



## 系统负载高
#### 统计系统调用耗时情况
```
strace -c -p pid
```

#### 跟踪指定的系统操作例如epoll_wait
```
strace -T -e epoll_wait -p pid
```


## 内核信息
#### 查看内核信息
```
dmesg
```


## 火焰图

### 说明
整个图形看起来就像一团跳动的火焰，这也正是其名字的由来。燃烧在火苗尖部的就是 CPU 正在执行的操作，不过需要说明的是颜色是随机的，本身并没有特殊的含义，纵向表示调用栈的深度，横向表示消耗的时间。因为调用栈在横向会按照字母排序，并且同样的调用栈会做合并，所以一个格子的宽度越大越说明其可能是瓶颈。综上所述，主要就是看那些比较宽大的火苗，特别留意那些类似平顶山的火苗。




### 安装依赖库
```
//必须按照systemtap，默认系统已安装
yum install systemtap systemtap-runtime

//内核调试库必须跟内核版本对应，例如：uname -r 2.6.18-308.el5
kernel-debuginfo-2.6.18-308.el5.x86_64.rpm
kernel-devel-2.6.18-308.el5.x86_64.rpm
kernel-debuginfo-common-2.6.18-308.el5.x86_64.rpm

//安装内核调试库
debuginfo-install --enablerepo=debuginfo search kernel
debuginfo-install --enablerepo=debuginfo  search glibc

```

### 安装步骤
```
git clone https://github.com/lidaohang/quick_location.git
cd quick_location
```


### CPU问题

#### on-CPU 用户态
执行中，执行中的时间通常又分为用户态时间user和系统态时间sys。

```

//on-CPU user
sh ngx_on_cpu_u.sh pid

//进入结果目录
cd ngx_on_cpu_u

//on-CPU kernel
sh ngx_on_cpu_k.sh pid

//进入结果目录
cd ngx_on_cpu_k

//开一个临时端口8088
python -m SimpleHTTPServer 8088 

//打开浏览器输入地址
127.0.0.1:8088/pid.svg

```



####  off-CPU 用户态

等待下一轮上CPU，或者等待I/O、锁、换页等等，其状态可以细分为可执行、匿名换页、睡眠、锁、空闲等状态。

```
// off-CPU user
sh ngx_off_cpu_u.sh pid

//进入结果目录
cd ngx_off_cpu_u

//off-CPU kernel
sh ngx_off_cpu_k.sh pid

//进入结果目录
cd ngx_off_cpu_k

//开一个临时端口8088
python -m SimpleHTTPServer 8088 

//打开浏览器输入地址
127.0.0.1:8088/pid.svg

```


### 内存问题

#### 内存上涨问题

```
sh ngx_on_memory.sh pid

//进入结果目录
cd ngx_on_memory

//开一个临时端口8088
python -m SimpleHTTPServer 8088 

//打开浏览器输入地址
127.0.0.1:8088/pid.svg

```
