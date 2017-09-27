
## 功能说明
 快速定位问题

## 定位步骤

###### 查看CPU高问题
`
./ngx_on_cpu.sh pid
`

`
perf top -e cpu-clock
perf top -p pid
`


###### 查看内存问题
`
./ngx_on_memory.sh pid
`

`
perf top -e faults
`

###### 查看系统IO
`
perf top -e block:block_rq_issue
`

###### 打印堆栈信息
`
pstack pid
`
