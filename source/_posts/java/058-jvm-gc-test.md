---
title: 触发5次ygc，然后3次fgc，然后3次ygc，然后1次fgc
tags:
  - java
p: java/058-jvm-gc-test
date: 2019-08-26 19:17:44
---

写一段程序，让其运行时的表现为触发5次ygc，然后3次fgc，然后3次ygc，然后1次fgc，请给出代码以及启动参数。

虽然答案不是我给出来的，这个参数我跳了很多次，3次、4次很好弄，但是5次不容易，网上也都是这一份代码，这里自己记录一份，做一些笔记。

JVM堆内存： 

```s
+--------------------+------+------+-----------------------------------------------+
|                    |      |      |                                               |
|                    |      |      |                                               |
|                    |      |      |                                               |
|                    | from | to   |                                               |
|       eden         |      |      |                  老  年  代                    |
|                    |      |      |                                               |
|                    |      |      |                                               |
|                    |  survivor   |                                               |
|                    |      |      |                                               |
+--------------------+------+------+-----------------------------------------------+
```

1. 新生代中：eden和survivor的比值默认为8:1， 可以通过`-XX:SurvivorRatio=8`调整
2. `-Xmn`声明新生代大小，下面也就是10MB，eden为8MB，survivor为1MB

```java
public class GcTest {

    private static final int _1MB = 1024 * 1024;

    /**
     * <p>
     * -Xms41M -Xmx41M -Xmn10M -XX:+PrintGCDetails
     * </p >
     *
     * @author jimo
     * @date 19-8-26 上午9:41
     */
    public static void main(String[] args) {

        MemoryMXBean mxBean = ManagementFactory.getMemoryMXBean();
        MemoryUsage heapMemoryUsage = mxBean.getHeapMemoryUsage();
        System.out.println("初始化堆：" + (heapMemoryUsage.getInit() >> 10) + "K");
        System.out.println("已用堆：" + (heapMemoryUsage.getUsed() >> 10) + "K");
        System.out.println("最大堆：" + (heapMemoryUsage.getMax() >> 10) + "K");

        List<byte[]> bytes = new ArrayList<>();
        for (int i = 0; i < 12; i++) {
            byte[] a = new byte[3 * _1MB];
            bytes.add(a);
///            System.out.println("剩余：" + (Runtime.getRuntime().freeMemory() >> 10) + "K");
        }

        bytes.remove(0);
        bytes.add(new byte[3 * _1MB]);

        bytes.subList(0, 8).clear();

        bytes.add(new byte[3 * _1MB]);
        for (int i = 0; i < 6; i++) {
            bytes.add(new byte[3 * _1MB]);
        }
    }
}
```

结果：
```s
初始化堆：43008K
已用堆：1549K
最大堆：41984K
[GC (Allocation Failure) [PSYoungGen: 7693K->560K(9216K)] 7693K->6712K(41984K), 0.0019230 secs] [Times: user=0.01 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 6860K->576K(9216K)] 13012K->12872K(41984K), 0.0016777 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 6851K->528K(9216K)] 19147K->18968K(41984K), 0.0019476 secs] [Times: user=0.01 sys=0.01, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 6813K->480K(9216K)] 25253K->25064K(41984K), 0.0018577 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 6772K->544K(9216K)] 31356K->31272K(41984K), 0.0017662 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[Full GC (Ergonomics) [PSYoungGen: 544K->0K(9216K)] [ParOldGen: 30728K->31085K(32768K)] 31272K->31085K(41984K), [Metaspace: 3045K->3045K(1056768K)], 0.0064061 secs] [Times: user=0.04 sys=0.00, real=0.01 secs] 
[Full GC (Ergonomics) [PSYoungGen: 6296K->3072K(9216K)] [ParOldGen: 31085K->31085K(32768K)] 37381K->34157K(41984K), [Metaspace: 3045K->3045K(1056768K)], 0.0051356 secs] [Times: user=0.04 sys=0.00, real=0.01 secs] 
[Full GC (Ergonomics) [PSYoungGen: 6299K->0K(9216K)] [ParOldGen: 31085K->12653K(32768K)] 37384K->12653K(41984K), [Metaspace: 3052K->3052K(1056768K)], 0.0035155 secs] [Times: user=0.03 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 6272K->0K(9216K)] 18926K->18797K(41984K), 0.0007275 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 6255K->0K(9216K)] 25053K->24941K(41984K), 0.0010805 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 6272K->0K(9216K)] 31214K->31085K(41984K), 0.0008488 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC (Ergonomics) [PSYoungGen: 0K->0K(9216K)] [ParOldGen: 31085K->31085K(32768K)] 31085K->31085K(41984K), [Metaspace: 3052K->3052K(1056768K)], 0.0014745 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
Heap
 PSYoungGen      total 9216K, used 3236K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
  eden space 8192K, 39% used [0x00000000ff600000,0x00000000ff9290e0,0x00000000ffe00000)
  from space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
  to   space 1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)
 ParOldGen       total 32768K, used 31085K [0x00000000fd600000, 0x00000000ff600000, 0x00000000ff600000)
  object space 32768K, 94% used [0x00000000fd600000,0x00000000ff45b620,0x00000000ff600000)
 Metaspace       used 3058K, capacity 4500K, committed 4864K, reserved 1056768K
  class space    used 326K, capacity 388K, committed 512K, reserved 1048576K
```

参考：

1. 《深入理解Java虚拟机--周志明》
2. [https://blog.csdn.net/chenhailonghp/article/details/93614904](https://blog.csdn.net/chenhailonghp/article/details/93614904)

