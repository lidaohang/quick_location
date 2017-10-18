# 故障定位

---

## cpu问题

#### 观察系统cpu使用情况
```
top

```

#### 进程级cpu的统计信息
```
pidstat -u 1 -p pid
```


#### 进程级cpu使用情况

```
perf top -p pid
```

## 查看所有cpu核信息
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

#### 统计cpu过热详细信息

```
perf record -F 99 -p 13204 -g -- sleep 30
perf report -n --stdio

```



## 内存
#### 查看内存使用情况
```
free -m
```

#### 观察内存情况
```
vmstat 1

```

#### 进程级别内存情况
```
#1s采集周期，获取内存的统计信息
pidstat -p pid -r 1
```





## 磁盘问题
#### 查看所有io信息
```
iotop
```

#### 获取进程级io的信息
```
pidstat -d 1 -p  pid
```

#### 统计io详细信息
```
iostat -d -x -k 1 10
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

tcpdump -i eth0 
 
#或者
 
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


## 深入nginx内部分析(todo)
#### 内部调用
```
strace -tttT -p 11838
```

## 内核信息
#### 查看内核信息
```
dmesg
```


## 火焰图

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

```

//on-CPU user
sh ngx_on_cpu_u.sh pid

//进入结果目录
cd ngx_on_cpu_u

//开一个临时端口8088
python -m SimpleHTTPServer 8088 

//打开浏览器输入地址
127.0.0.1:8088/pid.svg

```

#### on-CPU 内核态
```
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
```
// off-CPU user
sh ngx_off_cpu_u.sh pid

//进入结果目录
cd ngx_off_cpu_u

//开一个临时端口8088
python -m SimpleHTTPServer 8088 

//打开浏览器输入地址
127.0.0.1:8088/pid.svg

```

####  off-CPU 内核态
```
#off-CPU kernel
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





