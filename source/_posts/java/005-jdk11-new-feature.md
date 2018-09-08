---
title: jdk11新特性
tags:
  - java
p: java/005-jdk11-new-feature
date: 2018-09-08 15:20:32
---

如果您熟悉英文强烈建议阅读[官方文档](http://openjdk.java.net/projects/jdk/11/
)。

# java新增方法
当然，下面只是部分：

## String
```java
    @Test
    public void testString() {
        String s = " Jimo ";
        Assert.assertEquals("Jimo", s.strip());
        Assert.assertEquals("Jimo ", s.stripLeading());
        Assert.assertEquals(" Jimo", s.stripTrailing());
        Assert.assertFalse(s.isBlank());
        Assert.assertEquals(" Jimo  Jimo  Jimo ", s.repeat(3));

        var lines = "I'm a super man\ndo you know me?\n";
        final Stream<String> stringStream = lines.lines();
        System.out.println(stringStream.collect(Collectors.toList()));
        /*[I'm a super man, do you know me?]*/
    }
```
## File
```java
    @Test
    public void testFile() throws IOException {
        final Path path = Path.of("test.txt");
        Files.writeString(path, "Ha jimo");
        Assert.assertEquals("Ha jimo", Files.readString(path));

        Assert.assertTrue(Files.isSameFile(path, path));
    }
```
## Predicate
```java
    @Test
    public void testPredicate() {
        final long count = Stream.of("a", "b", "")
                .filter(Predicate.not(String::isEmpty))
                .count();
        Assert.assertEquals(2, count);

        final Predicate<String> predicate =
                Pattern.compile("jimo.").asMatchPredicate();
        Assert.assertTrue(predicate.test("jimo1"));
    }
```
## Thread
```java
    /**
     * @func Thread移除stop和destroy方法
     * @author wangpeng
     * @date 2018/8/27 8:37
     */
    @Test
    public void testThread() {
        final Thread t = new Thread();
        t.stop();
    }
```
## TimeUnit
```java
    @Test
    public void testTimeUnit() {
        final TimeUnit unit = TimeUnit.DAYS;
        Assert.assertEquals(2, unit.convert(Duration.ofHours(49)));
        Assert.assertEquals(1, unit.convert(Duration.ofMinutes(1450)));
    }
```
## lambda var
lambda表达式中支持可变参数var，并且可以注解.
```java
    @Test
    public void testParam() {
        final long count = Arrays
                .stream(new int[]{1, 2, 3, 4})
                .filter((@Nonnull var x) -> x > 2)
                .count();
        System.out.println(count);
    }
```
# 改进64位架构内部函数
改进现有的String和array内在函数，并在AArch64处理器上为java.lang.Math sin，cos和log函数实现新的内在函数。

原因：专用的CPU架构的代码模式可提高用户应用程序和基准测试的性能

下面分别在JDK8和JDK11上测试对比：
```java
    /**
     * @func 测试Math函数的时间, 看JDK11在优化了64位架构后有什么提升
     * @author wangpeng
     * @date 2018/8/25 19:24
     */
    @Test
    public void testMathOnJDK11() {
        final long startTime = System.nanoTime();
        for (int i = 0; i < 10000000; i++) {
            Math.sin(i);
            Math.cos(i);
            Math.log(i);
        }
        final long endTime = System.nanoTime();
        System.out.println(TimeUnit.NANOSECONDS.toMillis(endTime - startTime) + "ms");
        /*1279ms,1477ms*/
    }

    @Test
    public void testMathOnJDK8() {
        final long startTime = System.nanoTime();
        for (int i = 0; i < 10000000; i++) {
            Math.sin(i);
            Math.cos(i);
            Math.log(i);
        }
        final long endTime = System.nanoTime();
        System.out.println(TimeUnit.NANOSECONDS.toMillis(endTime - startTime) + "ms");
        /*8700ms ,8724ms*/
    }
```
# 移除Java EE和CORBA模块
JDK6包含完整的Web Service开发栈

## 名词解释
1. JAX-WS（基于XML的Web服务Java API），JAXB（用于XML绑定的Java架构），
JAF（JavaBeans Activation Framework）和Common Annotations

2. CORBA（Common Object Request Broker Architecture）通用对象请求代理架构是软件构建的一个标准

## 为什么移除？
1. JavaSE集成JavaEE存在问题：相关性，版本
2. Java EE的包可以很方便的从Maven等三方库获取
3. 并没多少人用JDK中的Java EE

# HTTP Client标准化
HTTP Client：JDK9提出，JDK10更新，JDK11标准化

从开始的孵化特性走向成熟，形成标准，有意思

JDK HTTP Client可用于通过网络请求HTTP资源；
1. 它支持HTTP / 1.1和HTTP / 2
2. 包括同步和异步编程模型，还支持并发
3. 将请求和响应主体作为反应流处理
4. 遵循熟悉的Builder模式。

```java
    @Test
    public void testGet() {
        final HttpClient client = HttpClient.newHttpClient();
        final HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://openjdk.java.net"))
                .build();
        client.sendAsync(request, HttpResponse.BodyHandlers.ofString())
                .thenApply(HttpResponse::body)
                .thenAccept(System.out::println)
                .join();
    }
```
# java单文件运行
http://openjdk.java.net/jeps/330
## 以前运行java文件

{% asset_img 000.png %}

{% asset_img 001.png %}

## 现在
{% asset_img 002.png %}

但是如果有内部类则找不到：

{% asset_img 003.png %}

# Filght Recorder(JFR)
http://openjdk.java.net/jeps/328

## 干什么的
1. 提供用于生成和使用数据作为事件的API
2. 提供缓冲机制和二进制数据格式
3. 允许配置和过滤事件
4. 为OS，HotSpot JVM和JDK库提供事件

## 为什么需要
故障排除，监视和分析是开发生命周期中不可或缺的部分，但是在涉及实际数据的繁重负载下，某些问题仅发生在生产中。

Flight Recorder记录来自应用程序，JVM和OS的事件。 事件存储在一个文件中，该文件可以附加到错误报告中并由支持工程师进行检查，允许事后分析导致问题时的问题。 工具可以使用API从记录文件中提取信息。

飞行记录嘛：飞机飞行时的记录，对于程序就是程序运行时的记录，包括状态监控和数据收集等

## 如何启动
{% asset_img 004.png %}

{% asset_img 005.png %}

## JFR-测试
```java
public class FlightRecorderTest extends Event {
    @Label("Hello World")
    @Description("Helps the programmer getting started")
    static class HelloWorld extends Event {
        @Label("Message")
        String message;
    }

    public static void main(String[] args) {
        HelloWorld event = new HelloWorld();
        event.message = "hello, world!";
        event.commit();
    }
}
```
运行时加上命令行参数：

{% asset_img 006.png %}

## 读取记录
```java
    /**
     * @func 读取jfr文件
     * @author wangpeng
     * @date 2018/8/26 16:52
     */
    @Test
    public void readRecordFile() throws IOException {
        final Path path = Paths.get("E:\\ws\\Git\\java-version-compare\\myrecording.jfr");
        final List<RecordedEvent> recordedEvents = RecordingFile.readAllEvents(path);
        for (RecordedEvent event : recordedEvents) {
            System.out.println(event.getStartTime() + "," + event.getValue("message"));
        }
    }
```

{% asset_img 007.png %}

https://docs.oracle.com/javacomponents/jmc-5-5/jfr-runtime-guide/run.htm#JFRRT164

# JDK11-低开销堆内存分析

提供一种从JVM获取有关Java对象堆分配的信息的方法：

1. 低开销
2. 可通过定义明确的程序接口访问，
3. 可以对所有分配进行采样（即，不限于在一个特定堆区域中的分配或以一种特定方式分配的分配），
4. 可以以与实现无关的方式定义（即，不依赖于任何特定的GC算法或VM实现）
5. 以及可以提供有关实时和死Java对象的信息。

## why
现有的堆内存工具：Java Flight Recorder, jmap, YourKit, and VisualVM

现在获取Hotspot信息的方式：
1. https://github.com/google/allocation-instrumenter
2. Java Flight Recorder：只能记录，不能定制采样间隔，不能区分死/活对象

## how
扩展了JVM TI：增加了分析接口

JVMTI(JVM Tool Interface)： JDK1.5提出，一般是C，C++实现该接口，在JVM启动时加载

http://openjdk.java.net/jeps/331

google开源内存分析工具：https://github.com/google/allocation-instrumenter

JVMTI介绍：https://en.wikipedia.org/wiki/Java_Virtual_Machine_Tools_Interface

Jvmti的使用：https://docs.oracle.com/javase/8/docs/platform/jvmti/jvmti.html

# JDK11-无操作(No-Op)GC
当堆内存枯竭时，JVM直接关闭，什么都不做 ，还有一个碉堡的名字：Epsilon 

## why
不同的垃圾回收器做不同的事嘛，存在即合理

1. 性能测试
2. 内存压力测试
3. VM接口测试
4. 生存期极短Job测试
5. 延时高敏感程序测试
6. 吞吐量提高

启动参数：`XX:+UseEpsilonGC`

http://openjdk.java.net/jeps/318

# JDK11-ZGC(实验性)
Z垃圾回收器，也称为ZGC，是一个可扩展的低延迟(scalable low-latency)垃圾回收器.
ZGC是一个并发的，单例的，基于区域的，NUMA感知的压缩回收器。 Stop-the-world阶段仅限于根扫描，因此GC暂停时间不会随堆或活动集的大小而增加

1. GC暂停时间不应超过10毫秒
2. 处理堆的大小从相对较小（几百MB）到非常大（TB）不等
3. 与使用G1相比，应用程序吞吐量减少不超过15％
4. 为未来的GC功能、优化利用彩色指针和负载屏障奠定基础
5. 最初支持的平台：Linux / x64

## 如何使用
使用：Linux/x64下编译JDK时：`--with-jvm-features=zgc`

命令行参数：`XX:+UnlockExperimentalVMOptions  -XX:+UseZGC`

## 比较
吞吐量：

{% asset_img 008.png %}

暂停时间：

{% asset_img 009.png %}

http://openjdk.java.net/jeps/333

# JDK11-TLS1.3
实现了传输层安全（TLS）协议RFC 8446的1.3版

TLS 1.3是TLS协议的重大改进，与以前的版本相比，它提供了显著的安全性和性能改进。 其他供应商的几个早期实现已经可用。 我们需要支持TLS 1.3以保持竞争力并与最新标准保持同步。

```java
    @Test
    public void useTLS() throws IOException {
        String host = "www.baidu.com";
        int port = 443;
        SocketFactory basicSocketFactory = SocketFactory.getDefault();
        Socket s = basicSocketFactory.createSocket(host, port);
        /*s 是一个 TCP socket*/
        SSLSocketFactory tlsSocketFactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
        s = tlsSocketFactory.createSocket(s, host, port, true);
        /*s 现在是一个 基于TCP的TLS socket*/
    }
```

TLS参考：http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html 

http://openjdk.java.net/jeps/332

RFC8446: https://tools.ietf.org/html/rfc8446

如何使用TLS：https://stackoverflow.com/questions/24868820/how-to-make-tls-work-with-java/24872636
http://www.java2s.com/Tutorial/Java/0490__Security/SSLClientSession.htm

传输层 https://zh.wikipedia.org/wiki/%E4%BC%A0%E8%BE%93%E5%B1%82

# JDK11-Curve25519 and Curve448
RFC 7748定义了一种密钥协商方案，该方案比现有的椭圆曲线Diffie-Hellman（ECDH）方案更有效（原来的是C实现的，现在可以用纯Java实现）和安全。 此JEP的主要目标是API和此标准的实现。

```java
    @Test
    public void keyAgreementTest() throws NoSuchAlgorithmException,
            InvalidAlgorithmParameterException, InvalidKeySpecException, InvalidKeyException {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("XDH");
        NamedParameterSpec paramSpec = new NamedParameterSpec("X25519");
        kpg.initialize(paramSpec);
        KeyPair kp = kpg.generateKeyPair();

        KeyFactory kf = KeyFactory.getInstance("XDH");
        BigInteger u = new BigInteger("1212324324");
        XECPublicKeySpec pubSpec = new XECPublicKeySpec(paramSpec, u);
        PublicKey pubKey = kf.generatePublic(pubSpec);

        KeyAgreement ka = KeyAgreement.getInstance("XDH");
        ka.init(kp.getPrivate());
        ka.doPhase(pubKey, true);
        byte[] secret = ka.generateSecret();
        System.out.println(Arrays.toString(secret));
    }
```

http://openjdk.java.net/jeps/324

RFC定义的椭圆算法：https://tools.ietf.org/html/rfc7748

# JDK11-Deprecate Nashorn
弃用Nashorn JavaScript脚本引擎和API以及jjs工具，在将来的版本中可能会删除它们，如果一群可靠的开发人员表达出对Nashorn前进的明确愿望，那么这个JEP可以取消的

原因：随着ECMAScript语言构建的快速步伐以及API的调整和修改，JDK发现Nashorn难以维护

http://openjdk.java.net/jeps/335

{% asset_img 010.png %}

# JDK11-基于Nest的访问控制
在以前的private public protected的基础上，JVM又提供了一种新的访问控制机制：Nest。

Java代码都是以类为单位组织的，而且即使是在一个.java文件中的多个类也都会被分别编译为不同的.class类文件。但是对于开发者来说，在一个源文件中的代码在逻辑上应该是可以互相访问的，但是Java并不直接允许这样做。我们虽然可以在一个匿名内部类中访问外层类的成员方法，但是这实际上是通过编译器自动生成的所谓 访问桥(access bridge) 方法进行访问。这个解决方案在解决一部分问题的同时，也带来了如增加了不必要的程序大小和额外性能损耗等问题，而且很容易迷惑一部分Java程序员。

而JDK 11带来的Nest就是一个更完善的解决方案。编译器现在把一些 看起来 是在一个类中的代码（如上面提到的匿名内部类）组织到Nest 中。而在同一个Nest中的类将会拥有同等的访问权限。这会让应用程序和字节码更加简单、安全，并对开发者透明。

Java作为一种相对保守的语言，这是少数几个对《Java语言规范》和《Java虚拟机规范》做出较大改动的JEP之一。然而对于普通开发者，在通常的开发中也不会有很大的变动。但是对于反射的重度使用者或接触字节码工程的人来说，这个JEP还是有必要仔细了解一下的。

http://openjdk.java.net/jeps/181

https://xsun.io/2018/06/29/jdk11-preview/

# JDK11-其他更新
```
更新到Unicode 10标准
Java SE 10实现了Unicode 8.0。 Unicode 9.0增加了7,500个字符和6个新脚本，Unicode 10.0.0增加了8,518个字符和4个新脚本。 此升级将包括Unicode 9.0更改，因此添加了总共16,018个字符和10个新脚本。
主要影响的类：
Character and String in the java.lang package,
NumericShaper in the java.awt.font package,
Bidi, BreakIterator, and Normalizer in the java.text package.

弃用Pack200工具和API
在java.util.jar中弃用pack200和unpack200工具以及Pack200 API。

实现ChaCha20和Poly1305密码算法
实现RFC 7539中指定的ChaCha20和ChaCha20-Poly1305密码.ChaCha20是一种相对较新的流密码，可以替代旧的，不安全的RC4流密码。

动态类文件常量
这个JEP扩展了Java类文件格式来支持一种新形式的常量池，CONSTANT_Dynamic。它在初始化的时候，会像invokedynamic指令生成代理方法一样，委托给一个初始化方法进行创建。这是一个JVM内部的特性，对上层软件没有很大的影响，但是为Java语言未来的重大变化铺设了道路。
```

Unicode10：http://openjdk.java.net/jeps/327

Pack200：http://openjdk.java.net/jeps/336

http://openjdk.java.net/jeps/309


# 参考
[https://dzone.com/articles/features-of-java-11
](https://dzone.com/articles/features-of-java-11
)

[http://openjdk.java.net/jeps/320
](http://openjdk.java.net/jeps/320
)

http://openjdk.java.net/jeps/321

HTTP Client的用法：http://openjdk.java.net/groups/net/httpclient/recipes.html

Client介绍：http://openjdk.java.net/groups/net/httpclient/intro.html


