---
title: redis配置文件
tags:
  - redis
p: lang/010-redis-configuration
date: 2018-09-04 08:12:15
---

本文解释redis的配置文件。

# 配置文件位置
默认安装包下就有,当然也可以自己创建。

```shell
[root@jimo redis-4.0.11]# ls
00-RELEASENOTES  BUGS  CONTRIBUTING  COPYING  INSTALL  MANIFESTO  Makefile  README.md  deps  redis.conf  runtest  runtest-cluster  runtest-sentinel  sentinel.conf  src  tests  utils
```

本文基于`redis.conf`。

# 如何使用redis.conf
```shell
./redis-server /path/to/redis.conf
```
# 容量解释
```
# 1k => 1000 bytes
# 1kb => 1024 bytes
# 1m => 1000000 bytes
# 1mb => 1024*1024 bytes
# 1g => 1000000000 bytes
# 1gb => 1024*1024*1024 bytes
```
不区分大小写，也就是说：1GB=1gB=1Gb

# 包含其他配置文件
为避免被覆盖，最好放在文件结尾：
```
# include /path/to/local.conf
# include /path/to/other.conf
```
# 加载模块
在启动时加载模块，如果加载失败则无法启动。
```
# loadmodule /path/to/my_module.so
# loadmodule /path/to/other_module.so
```
# 网络
## bind
如果没有如下示例的`bind`，则server监听所有网卡。
```
# bind 192.168.1.100 10.0.0.1
# bind 127.0.0.1 ::1
```
***警告: 如果运行Redis的计算机直接暴露在互联网，绑定到所有接口是危险的，这将暴露对互联网上的每个人都有一个实例。 所以默认情况下我们取消注释遵循bind指令，这将强制Redis只监听IPv4回溯接口地址（这意味着Redis将能够仅接受来自运行到同一台计算机的客户端的连接在跑）*** 。

默认情况，绑定到本地：
```
bind 127.0.0.1
```
## 保护模式
```
protected-mode yes
```
保护模式默认打开，可以避免暴露到网络上被攻击或访问。

如果保护模式打开，且满足：
1. 没有`bind`指令
2. 没配置密码

则redis只接受127.0.0.1 和 ::1的客户端。
## TCP backlog
```
#默认值 511 
tcp-backlog：511
```

此参数确定了TCP连接中已完成队列(完成三次握手之后)的长度， 当然此值 **必须不大于Linux系统定义的** `/proc/sys/net/core/somaxconn`值，默认是511，而Linux的默认参数值是128。当系统并发量大并且客户端速度缓慢的时候，可以将这二个参数一起参考设定。

**建议修改为 2048**

修改somaxconn

该内核参数默认值一般是128，对于负载很大的服务程序来说大大的不够。一般会将它修改为2048或者更大。
```
# cat /proc/sys/net/core/somaxconn
128
```

`echo 2048 > /proc/sys/net/core/somaxconn` 但是这样系统重启后保存不了

在`/etc/sysctl.conf`中添加如下`net.core.somaxconn = 2048`

然后在终端中执行`sysctl -p`.

## port
监听端口，如果为0，则不监听。
```
port 6379
```
## unix socket
监听unix的socket连接，没有设置则不监听。
```
# unixsocket /tmp/redis.sock
# unixsocketperm 700
```
## timeout
在客户端空闲N秒后关闭连接（0表示禁用）
```
timeout 0
```
## TCP keepalive
如果非0，则在没有通信的情况下使用SO_KEEPALIVE向客户端发送TCP ACK。 这有两个原因：

1. 检测死的客户端。
2. 从中间网络设备的角度看有效连接。

 在Linux上，指定的值（以秒为单位）是用于发送ACK的时间段。 请注意，要关闭连接，需要两倍的时间。 在其他内核上，周期取决于内核配置。

此选项的合理值为300秒，这是从Redis 3.2.1开始的新Redis默认值。
```
tcp-keepalive 300
```
# 通用配置
## 守护程序
默认redis不开守护程序，如果打开，会写一个pid文件到`/var/run/redis.pid`
```
daemonize no
```
## supervised
如果从upstart或systemd运行Redis，Redis可以与您的监督树进行交互:
* supervised no - 不交互
* supervised upsert - 将redis放入SIGSTOP模式与upstart发信号
* supervised systemd - 通过写入READY=1到$NOTIFY_SOCKET与systemd交互
* supervised auto - 通过UPSERT_JOB 或 NOTIFY_SOCKET环境变量检测upstart或systemd方法

他们只发送“进程准备好”的信号，并不保持持续的ping连接。
```
supervised no
```
## pid file
指定的pid文件会在启动时写入，退出时移除。

* 如果守护进程关闭：pid文件不会创建；
* 否则一定会使用，默认是：`/var/run/redis.pid`

最好指定一个pid文件，即使无法创建也不会报错：
```
pidfile /var/run/redis_6379.pid
```
## loglevel
有`debug,verbose,notice,warning`,默认notice(生产环境)
```
loglevel notice
```
## logfile
如果为`""`,则输出到标准输出，如果同时还开启了守护进程，则转到`/dev/null`:
```
logfile ""
```
## syslog-enabled
```
# syslog-enabled no
```
## syslog-ident
系统日志的主体(identity)
```
# syslog-ident redis
```
## syslog-facility
指定syslog工具, 必须是USER或LOCAL0-LOCAL7之间。
```
# syslog-facility local0
```
## databases
设置数据库的数量。 默认数据库是DB 0，您可以使用`SELECT <dbid>`在每个连接上选择不同的数据库，其中dbid是介于0和'databases'-1之间的数字
```
databases 16
```
## always-show-logo
默认情况下，只有在开始登录标准输出且标准输出为TTY时，Redis才会显示ASCII艺术徽标。 基本上这意味着通常只在交互式会话中显示徽标。

但是，通过将以下选项设置为yes，可以强制执行4.0之前的行为并始终在启动日志中显示ASCII艺术徽标。
```
always-show-logo yes
```

# 快照

## save
将数据库保存在磁盘上：
```
    save <秒> <更改数量>

    如果同时发生了给定的秒数和针对DB的给定写入操作数，则将保存数据库。

    在下面的示例中，行为将是保存：
    如果至少1个键改变，则在900秒（15分钟）之后
    如果至少改变了10个键，则在300秒（5分钟）后
    如果至少10000键改变，60秒后

    注意：您可以通过注释掉所有“save”行来完全禁用保存。

    也可以通过添加带有单个空字符串参数的save指令来删除所有先前配置的保存点，如下例所示：

    save ""

save 900 1
save 300 10
save 60 10000
```
## stop-writes-on-bgsave-error
默认情况下，如果启用了RDB快照（至少一个保存点）并且最新的后台保存失败，Redis将停止接受写入。 这将使用户意识到（以一种困难的方式）数据没有正确地保存在磁盘上，否则很可能没有人会注意到并且会发生一些灾难。

如果后台保存过程将再次开始工作，Redis将自动再次允许写入。

但是，如果您已设置对Redis服务器和持久性的正确监视，则可能需要禁用此功能，以便即使磁盘，权限等存在问题，Redis也将继续正常工作。
```
stop-writes-on-bgsave-error yes
```
## rdbcompression
转储.rdb数据库时使用LZF压缩字符串对象？ 默认设置为“是”，因为它几乎总是一个好处。 如果要在保存子项中节省一些CPU，请将其设置为“否”，但如果您具有可压缩值或键，则数据集可能会更大。
```
rdbcompression yes
```
## rdbchecksum
从RDB的第5版开始，CRC64校验和被放置在文件的末尾。 这使得格式更能抵抗损坏，但在保存和加载RDB文件时需要支付性能（大约10％），因此您可以禁用它以获得最佳性能。

禁用校验和创建的RDB文件的校验和为零，将告诉加载代码跳过检查。
```
rdbchecksum yes
```
## dbfilename
转储数据库的文件名
```
dbfilename dump.rdb
```
## dir
工作目录。

数据库将使用'dbfilename'配置的文件名写入此目录。还将在此目录中创建仅可追加文件。

请注意，您必须在此处指定目录，而不是文件名。
```
dir ./
```
# 复制
## slaveof
主从复制。 使用slaveof使Redis实例成为另一台Redis服务器的副本。 关于Redis复制的一些事情要尽快理解。

1. Redis复制是异步的，但是如果主机看起来与至少给定数量的从站没有连接，则可以配置主机停止接受写入。
2. 如果复制链路丢失了相对较短的时间，Redis从站能够与主站进行部分重新同步。 您可能希望根据需要配置具有合理值的复制积压大小（请参阅此文件的下一部分）。
3. 复制是自动的，不需要用户干预。 在网络分区从属设备自动尝试重新连接到主设备并与它们重新同步之后。
```
# slaveof <masterip> <masterport>
```
## masterauth
如果主服务器受密码保护（使用下面的“requirepass”配置指令），则可以在启动复制同步过程之前告知从服务器进行身份验证，否则主服务器将拒绝从服务器请求。
```
masterauth <master-password>
```
## slave-serve-stale-data
stale: 陈旧的，过时的

当从属设备失去与主设备的连接时，或者当复制仍在进行时，从设备可以以两种不同的方式操作：

1. 如果slave-serve-stale-data设置为“yes”（默认值），则slave仍将回复客户端请求，可能是过期数据，或者如果这是第一次同步，则数据集可能只是空。

2. 如果slave-serve-stale-data设置为'no'，则slave将回复一个错误“SYNC with master in progress”到所有类型的命令，除了INFO和SLAVEOF。

```
slave-serve-stale-data yes
```
## slave-read-only
您可以将从属实例配置为是否接受写入。 针对从属实例进行写入可能对存储一些短暂的数据很有用（因为在与主服务器重新同步后，将很容易删除写在从服务器上的数据），但如果客户端由于配置错误而写入数据，也可能会导致问题。

由于Redis 2.6默认情况下从属设备是只读的。

**注意：只读从站不适合在Internet上暴露给不受信任的客户端。 它只是一个防止滥用实例的保护层。 仍然只读的从属设备默认导出所有管理命令，如CONFIG，DEBUG等。 在某种程度上，您可以使用“rename-command”来隐藏所有管理/危险命令，从而提高只读从站的安全性**。
```
slave-read-only yes
```
## repl-diskless-sync
复制SYNC策略：磁盘或套接字。

-------------------------------------------------- -----
**警告：目前无盘复制是实验性的**
-------------------------------------------------- -----

新的从站和重新连接的从站只能接收差异而无法继续复制过程，需要执行所谓的“完全同步”。 RDB文件从主服务器传输到从服务器。传输可以以两种不同的方式发生：

1. 磁盘：Redis主服务器创建一个将RDB文件写入磁盘的新进程。稍后，父进程将文件以递增方式传输到从属服务器。
2. 无盘：Redis主站创建一个新进程，直接将RDB文件写入从套接字，而根本不接触磁盘。

使用磁盘支持的复制，在生成RDB文件时，只要生成RDB文件的当前子代完成其工作，就可以将更多的从服务器排队并与RDB文件一起提供。使用无盘复制，一旦传输开始，到达的新从站将排队，并且当当前终端将终止时将开始新的传输。

使用无盘复制时，主机在开始传输之前等待一段可配置的时间（以秒为单位），希望多个从站到达并且传输可以并行化。

对于慢速磁盘和快速（大带宽）网络，无盘复制效果更好。
```
repl-diskless-sync no
```
## repl-diskless-sync-delay
启用无盘复制时，可以配置服务器等待的延迟，以便生成通过套接字将RDB传输到从属服务器的子服务器。

这很重要，因为一旦传输开始，就不可能为新的从站提供服务，这些新的服务器将排队等待下一次RDB传输，因此服务器会等待延迟以便让更多的从服务器到达。

延迟以秒为单位指定，默认为5秒。 要完全禁用它，只需将其设置为0秒，即可尽快启动传输。
```
repl-diskless-sync-delay 5
```
## repl-ping-slave-period 
从站以预定义的间隔将PING发送到服务器。 可以使用repl_ping_slave_period选项更改此间隔。 默认值为10秒。
```
repl-ping-slave-period 10
```
## repl-timeout
以下选项设置复制超时：

1. 从从设备的角度来看，在SYNC期间批量传输I / O.
2. 从站（data，ping）的角度来看主站超时。
3. 从主设备的角度来看从设备超时（REPLCONF ACK ping）。

**确保此值大于为repl-ping-slave-period指定的值非常重要，否则每次主站和从站之间的流量较低时都会检测到超时。**

```
repl-timeout 60
```
## repl-disable-tcp-nodelay
SYNC后，在从站socket禁用TCP_NODELAY？

如果选择“是”，Redis将使用较少数量的TCP数据包和较少的带宽将数据发送到从设备。 但这可能会增加数据在从属端出现的延迟，使用默认配置的Linux内核最多可达40毫秒。

如果选择“否”，将减少从站侧出现数据的延迟，但将使用更多带宽进行复制。

默认情况下，我们针对低延迟进行了优化，但是在非常高的流量条件下，或者当主设备和从设备远离许多跳时，将其转为“是”可能是个好主意。
```
repl-disable-tcp-nodelay no
```
## repl-backlog-size
设置复制积压大小。 积压是一个缓冲区，当从属设备断开连接一段时间后会累积从属数据，这样当一个从属设备想要再次重新连接时，通常不需要完全重新同步，只是部分重新同步就足够了。

复制积压越大，从站断开连接的时间就可以越长。

只有在至少连接了一个从站时才会分配积压。
```
repl-backlog-size 1mb
```
## repl-backlog-ttl 
在主设备不再连接从设备一段时间后，将释放待办事项。 以下选项配置从上次从站断开连接开始需要经过的秒数，以释放待处理日志缓冲区。

请注意，从站永远不会因为超时释放积压，因为它们可能会在以后升级为主站，并且应该能够与从站正确“部分重新同步”：因此它们应始终积累积压。

值为0表示永远不会释放积压。
```
repl-backlog-ttl 3600
```
## slave-priority 
从属优先级一个整数。 如果主服务器不再正常工作，Redis Sentinel将使用它来选择要升级为主服务器的从服务器。

具有 **低优先级编号的从站被认为更适合升级** ，因此例如如果有三个优先级为10,100的从站，则Sentinel将选择优先级为10的从站，即最低的。

但是，**特殊优先级为0表示从站无法执行主站角色**，因此Redis Sentinel永远不会选择优先级为0的从站进行升级。

默认情况下，优先级为100。
```
slave-priority 100
```
## min-slaves-to-write
如果连接的连接少于N个，滞后<= M秒，则主设备可以停止接受写入。

N个奴隶需要处于“在线”状态。

以秒为单位的延迟（必须<= 指定值）是根据从从站接收的最后一次ping计算的，通常每秒发送一次。

此选项不保证N个副本将接受写入，但是如果没有足够的从站可用，则将限制丢失写入的窗口，达到指定的秒数。

例如，要求至少3个具有滞后<= 10秒的从属使用：
```
min-slaves-to-write 3
min-slaves-max-lag 10
```
将一个或另一个设置为0将禁用该功能。

默认情况下，min-slaves-to-write设置为0（功能禁用），min-slaves-max-lag设置为10。
## slave-announce
Redis主站能够以不同方式列出所连接从站的地址和端口。例如，“INFO复制”部分提供此信息，Redis Sentinel使用该信息以及其他工具来发现从属实例。
此信息可用的另一个位置是主站的“ROLE”命令的输出。

通常由从站报告的列出的IP和地址通过以下方式获得：

* IP：通过检查从设备用于连接主设备的套接字的对等地址，自动检测地址。
* 端口：端口在复制握手期间由从端进行通信，通常是从端用于列出连接的端口。

但是，当使用端口转发或网络地址转换（NAT）时，从站实际上可以通过不同的IP和端口对访问。从站可以使用以下两个选项，以便向其主站报告一组特定的IP和端口，以便INFO和ROLE都报告这些值。

如果只需要覆盖端口或IP地址，则无需使用这两个选项。
```
# slave-announce-ip 5.5.5.5
# slave-announce-port 1234
```




