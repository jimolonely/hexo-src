---
title: 如何得到一个java进程消耗的内存
tags:
  - java
  - linux
p: java/031-java-process-memory-usage
date: 2019-03-06 16:28:24
---

虽然这个问题很简单，但可以结合很多方面的东西，如果想深究的话，会是个不错的实践机会。

# 得到进程ID
这一步有很多方式，用ps，jps都可以：
```shell
# jps -l | grep xxx
8408 xxx.jar
```

# 得到进程总内存

java进程虽然特殊，但也是一个进程，可以用传统方式获得：
## ps + grep
```shell
# ps auwx | egrep "MEM|8408" | grep -v grep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      8408  1.0  0.6 10055952 1702180 ?    Sl   2月27 108:27 java -Xmx800m -Xms800m -jar ...
```
可以看到占用了`0.6%`的内存，机器总共270G内存，所以占了大约：1.6G。

1. RSS: 常驻内存集（Resident Set Size）
    1. 不包括进入交换分区的内存
    2. 包括共享库占用的内存（只要共享库在内存中）
    3. 包括所有分配的栈内存和堆内存
2. 表示进程分配的虚拟内存
    1. 包括进程可以访问的所有内存
    2. 包括进入交换分区的内容
    3. 以及共享库占用的内存。

```
如果一个进程，程序的大小有 500K，链接的共享库大小有 2500K，堆栈内存共有 200K，其中 100K 进入了交换分区。
进程实际加载了共享库中的 1000K 的内容，以及自己程序的中的 400K 的内容。请问 RSS 和 VSZ 应是多少？

RSS: 400K + 1000K + 100K = 1500K
VSZ: 500K + 2500K + 200K = 3200K

RSS 中有一部分来自共享库，而共享库可能被许多进程使用，所以如果把所有进程的 RSS 加起来，可能比系统内存还要大。
```
参考[stackoverflow](https://stackoverflow.com/questions/7880784/what-is-rss-and-vsz-in-linux-memory-management)

## pmap
// TODO pmap介绍
pmap可以查看进程的内存映射，字段解释如下：

1. Address: 内存开始地址
2. Kbytes: 可使用内存的字节数（KB）
3. RSS: 常驻内存（Resident Set Size）
4. Dirty: 脏页的字节数（包括共享和私有的）（KB）
5. Mode: 内存的权限：read、write、execute、shared、private (写时复制)
6. Mapping: 占用内存的文件、或[anon]（分配的内存）、或[stack]（堆栈）

```shell
# pmap -x 8408
8408:   java -Xmx800m -Xms800m -jar xxx.jar --spring.profiles.active=self-test 
Address           Kbytes     RSS   Dirty Mode  Mapping
0000000000400000       4       4       0 r-x-- java
0000000000600000       4       4       4 rw--- java
...
---------------- ------- ------- ------- 
total kB         10055956 1702372 1687060
```
可以看到RSS, Kbytes 和ps的RSS,VSZ差不多。

但是，我们还是不知道进程到底占用了多少内存，精确值！

## 更好的方式
来自：[In Linux, how to tell how much memory processes are using?
](https://stackoverflow.com/questions/3853655/in-linux-how-to-tell-how-much-memory-processes-are-using)
```shell
# echo 0 $(awk '/Pss/ {print "+", $2}' /proc/8408/smaps ) | bc
1688609
```

**但细心点会发现，我们配置的最大堆内存是800m，但实际使用1.6G左右，差别这么大，要知道为什么，就需要研究JVM的内存结构了。**

## jmap

```shell
# jmap -heap 8408
Attaching to process ID 8408, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.121-b13

using thread-local object allocation.
Parallel GC with 13 thread(s)

Heap Configuration:
   MinHeapFreeRatio         = 0
   MaxHeapFreeRatio         = 100
   MaxHeapSize              = 838860800 (800.0MB)
   NewSize                  = 279445504 (266.5MB)
   MaxNewSize               = 279445504 (266.5MB)
   OldSize                  = 559415296 (533.5MB)
   NewRatio                 = 2
   SurvivorRatio            = 8
   MetaspaceSize            = 21807104 (20.796875MB)
   CompressedClassSpaceSize = 1073741824 (1024.0MB)
   MaxMetaspaceSize         = 17592186044415 MB
   G1HeapRegionSize         = 0 (0.0MB)

Heap Usage:
PS Young Generation
Eden Space:
   capacity = 217579520 (207.5MB)
   used     = 21994848 (20.975921630859375MB)
   free     = 195584672 (186.52407836914062MB)
   10.10887789439006% used
From Space:
   capacity = 30408704 (29.0MB)
   used     = 24198456 (23.07744598388672MB)
   free     = 6210248 (5.922554016113281MB)
   79.57739994443696% used
To Space:
   capacity = 31457280 (30.0MB)
   used     = 0 (0.0MB)
   free     = 31457280 (30.0MB)
   0.0% used
PS Old Generation
   capacity = 559415296 (533.5MB)
   used     = 467722072 (446.05452728271484MB)
   free     = 91693224 (87.44547271728516MB)
   83.60909602300184% used

53860 interned Strings occupying 6265912 bytes.
```

## jstat

[广泛文档解释](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstat.html)

```shell
# jstat -gc 8408
 S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT   
30720.0 29696.0  0.0   23631.3 212480.0 144045.1  546304.0   456759.8  126936.0 120538.9 15104.0 14010.6    529   22.484   4      0.592   23.076
[root@hadoop5 ~]# jstat -gccapacity 8408
 NGCMN    NGCMX     NGC     S0C   S1C       EC      OGCMN      OGCMX       OGC         OC       MCMN     MCMX      MC     CCSMN    CCSMX     CCSC    YGC    FGC 
272896.0 272896.0 272896.0 30720.0 29696.0 212480.0   546304.0   546304.0   546304.0   546304.0      0.0 1161216.0 126936.0      0.0 1048576.0  15104.0    529     4
```

# 再看
但是堆内存一切正常，还没用完呢，为啥虚拟内存占了那么多？ 偶然，查看pmap时发现大量64MB的分配：
```shell
# pmap -x 8408 | grep 65404 
00007f4e3c021000   65404       0       0 -----   [ anon ]
00007f4e50021000   65404       0       0 -----   [ anon ]
00007f4e58021000   65404       0       0 -----   [ anon ]
00007f4e60021000   65404       0       0 -----   [ anon ]
00007f4e74021000   65404       0       0 -----   [ anon ]
00007f4e78021000   65404       0       0 -----   [ anon ]
00007f4e7c021000   65404       0       0 -----   [ anon ]
00007f4e80021000   65404       0       0 -----   [ anon ]
00007f4e88021000   65404       0       0 -----   [ anon ]
00007f4e8c021000   65404       0       0 -----   [ anon ]
00007f4e90021000   65404       0       0 -----   [ anon ]
00007f4e94021000   65404       0       0 -----   [ anon ]
00007f4e98021000   65404       0       0 -----   [ anon ]
00007f4ea0021000   65404       0       0 -----   [ anon ]
00007f4ea8021000   65404       0       0 -----   [ anon ]
00007f4eac021000   65404       0       0 -----   [ anon ]
00007f4eb0021000   65404       0       0 -----   [ anon ]
00007f4ecc021000   65404       0       0 -----   [ anon ]
00007f4ed0021000   65404       0       0 -----   [ anon ]
00007f4ed4021000   65404       0       0 -----   [ anon ]
00007f4f04021000   65404       0       0 -----   [ anon ]
00007f4f08021000   65404       0       0 -----   [ anon ]
00007f4f0c021000   65404       0       0 -----   [ anon ]
00007f4f10021000   65404       0       0 -----   [ anon ]
00007f4f14021000   65404       0       0 -----   [ anon ]
00007f4f18021000   65404       0       0 -----   [ anon ]
00007f4f1c021000   65404       0       0 -----   [ anon ]
00007f4f20021000   65404       0       0 -----   [ anon ]
00007f4f24021000   65404       0       0 -----   [ anon ]
00007f4f28021000   65404       0       0 -----   [ anon ]
00007f4f2c021000   65404       0       0 -----   [ anon ]
00007f4f30021000   65404       0       0 -----   [ anon ]
00007f4f34021000   65404       0       0 -----   [ anon ]
00007f4f38021000   65404       0       0 -----   [ anon ]
00007f4f3c021000   65404       0       0 -----   [ anon ]
00007f4f40021000   65404       0       0 -----   [ anon ]
00007f4f44021000   65404       0       0 -----   [ anon ]
00007f4f4c021000   65404       0       0 -----   [ anon ]
...
```
总共有近60个，于是查明了原因： [当Java虚拟机遇上Linux Arena内存池](https://cloud.tencent.com/developer/article/1054839)





