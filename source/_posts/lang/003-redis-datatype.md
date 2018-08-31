---
title: redis数据类型
tags:
  - redis
p: lang/003-redis-datatype
date: 2018-08-31 14:10:00
---

Redis不是普通的键值存储，它实际上是一个数据结构服务器，支持不同类型的值。 这意味着，在传统的键值存储中，您将字符串键与字符串值相关联，在Redis中，值不仅限于简单的字符串，还可以包含更复杂的数据结构。 以下是Redis支持的所有数据结构的列表，本教程将单独介绍它们：
* 安全的二进制字符串。
* 列表：根据插入顺序排序的字符串元素的集合。它们基本上是链表。
* 集合：唯一的未排序字符串元素的集合。
* 排序集(sorted set)，类似于集，但每个字符串元素与浮点数值相关联，称为分数。元素总是按其分数排序，因此与集合不同，可以检索一系列元素（例如，您可能会问：给我前10个，或者下10个）。
* 散列，是由与值相关联的字段组成的映射。字段和值都是字符串。这与Ruby或Python哈希非常相似。
* 位数组（或简称位图）：可以使用特殊命令处理字符串值，如位数组：您可以设置和清除各个位，将所有位设置为1，查找第一组或未设置位，等等。
* HyperLogLogs：这是一个概率数据结构，用于估计集合的基数。不要害怕，它比看起来更简单...请参阅本教程的HyperLogLog部分。

# Redis Keys
Redis键是二进制安全的，这意味着您可以使用任何二进制序列作为键，从“foo”这样的字符串到JPEG文件的内容。空字符串也是有效键。

关于键的一些其他规则：

* 很长的Key不是一个好主意。例如，1024字节的key不仅是内存方面的坏主意，而且因为在数据集中查找key可能需要几次昂贵的key比较。即使当前的任务是匹配大值的存在，hash它（例如使用SHA1）也是一个更好的主意，特别是从内存和带宽的角度来看。
* 非常短的键往往不是一个好主意。如果您可以改写“user：1000：followers”，那么将“u1000flw”写为关键字几乎没有意义。前者更易读，与key和值使用的空间相比，增加的空间较小。虽然短键显然会消耗更少的内存，但您的工作就是找到合适的平衡点。
* 尝试坚持使用架构。例如，“object-type：id”是一个好主意，如“user：1000”。点或短划线通常用于多字词字段，如“comment：1234：reply.to”或“comment：1234：reply-to”。
* 允许的最大key大小为512 MB。

# Redis Strings
Redis String类型是可以与Redis密钥关联的最简单的值类型。 它是Memcached中唯一的数据类型，因此对于新手来说，在Redis中使用它也是非常自然的。

由于Redis键是字符串，当我们使用字符串类型作为值时，我们将字符串映射到另一个字符串。 字符串数据类型对许多用例很有用，例如缓存HTML片段或页面。

让我们使用redis-cli对字符串类型进行一些操作（所有示例都将在本教程中通过redis-cli执行）。
```
> set mykey somevalue
OK
> get mykey
"somevalue"
```
正如您所看到的，使用SET和GET命令是我们设置和检索字符串值的方式。 请注意，即使key与非字符串值相关联，SET也将替换已存在于key中的任何现有值。 所以SET执行一项赋值任务。

值可以是各种字符串（包括二进制数据），例如，您可以将jpeg图像存储在值中。 值不能大于512 MB。

SET命令有一些有趣的选项，它们作为附加参数提供。 例如，如果key已经存在，我可能会要求SET失败，或者相反(如果key存在也能成功）：
```
> set mykey newval xx # 只有mykey存在(exist)才会成功，所以失败了
(nil)
> set mykey newval nx # mykey不存在(not exist)也会成功，默认就是
OK
```
即使字符串是Redis的基本值，也可以使用它们执行有趣的操作。 例如，一个是原子增量：
```
> set counter 100
OK
> incr counter
(integer) 101
> incr counter
(integer) 102
> incrby counter 50
(integer) 152
```
INCR命令将字符串值解析为整数，将其递增1，最后将获取的值设置为新值。还有其他类似的命令，如INCRBY，DECR和DECRBY。在内部，它始终是相同的命令，以稍微不同的方式运作。

INCR是原子的意味着什么？即使是针对相同key发布INCR的多个客户端也不会进入竞争状态。例如，客户端1读取“10”和客户端2同时读取“10”，两者都增加到11，并将新值设置为11 永远不会发生. 并且当所有其他客户端不同时执行读取命令时或执行增量设置操作，最终值将始终为12。

有许多用于操作字符串的命令。例如，GETSET命令将键设置为新值，并将旧值作为结果返回。例如，如果您的系统在每次网站收到新访问者时使用INCR递增Redis key，则可以使用此命令。您可能希望每小时收集一次此信息，而不会丢失一个增量。您可以GETSET键，为其指定新值“0”并返回旧值。

在单个命令中设置或检索多个键的值的能力对于减少延迟也是有用的。 因此，有MSET和MGET命令：
```
> mset a 10 b 20 c 30
OK
> mget a b c
1) "10"
2) "20"
3) "30"
```
# 修改和查询key空间
有些命令没有在特定类型上定义，但是为了与键的空间交互很有用，因此可以与任何类型的键一起使用。

例如，EXISTS命令返回1或0以表示数据库中是否存在给定键，而DEL命令删除键和关联值，无论值是什么。
```
> set mykey hello
OK
> exists mykey
(integer) 1
> del mykey
(integer) 1
> exists mykey
(integer) 0
```
从示例中，您还可以看到DEL本身如何返回1或0，具体取决于key是否被删除（它是否存在）（没有具有该名称的key）。

有许多与key空间相关的命令，但上面两个是与TYPE命令一起必不可少的命令，它返回存储在指定键中的值的类型：
```
> set mykey x
OK
> type mykey
string
> del mykey
(integer) 1
> type mykey
none
```
# Redis到期：生存时间有限的key
在继续使用更复杂的数据结构之前，我们需要讨论另一个无论值类型如何都能工作的特性，并称为Redis过期。 您可以为key设置超时，这是一个有限的生存时间。 当生存时间过去时，key会自动销毁，就像用户使用key调用DEL命令一样。

关于Redis到期的一些快速信息：

* 它们可以使用秒或毫秒精度进行设置。
* 但是，到期时间分辨率始终为1毫秒。
* 有关过期的信息将被复制并保留在磁盘上，当Redis服务器保持停止时，这个时间实际上会消失（这意味着Redis会在key即将过期时保存key过期的日期）。

设置过期是很容易的：
```
> set key some-value
OK
> expire key 5
(integer) 1
> get key (immediately)
"some-value"
> get key (after some time)
(nil)
```
两个GET调用之间的key消失了，因为第二个调用被延迟超过5秒。 在上面的示例中，我们使用EXPIRE来设置（它也可以用来设置一个已经有一个过期时间的键的不同过期时间，就像PERSIST可以用来删除过期时间并使key永久持久化）。 但是，我们也可以使用其他Redis命令创建过期密钥。 例如，使用SET选项：
```
> set key 100 ex 10
OK
> ttl key
(integer) 9
```
上面的示例设置一个字符串值为100的密钥，其过期为十秒。 稍后调用TTL命令以检查密钥的剩余生存时间。

要以毫秒为单位设置和检查过期，请检查PEXPIRE和PTTL命令以及SET选项的完整列表。

```
127.0.0.1:6379> set k jimo px 5000                                                               
OK                                                                                               
127.0.0.1:6379> ttl k                                                                            
(integer) 1                                                                                      
127.0.0.1:6379> ttl k                                                                            
(integer) -2     
```
# Redis列表
为了解释List数据类型，最好从一点理论开始，因为术语List经常被信息技术人员以不正当的方式使用。例如，“Python Lists”不是名称所暗示的（Linked Lists），而是Arrays（实际上相同的数据类型在Ruby中称为Array）。

从非常一般的角度来看，List只是一系列有序元素：10,20,1,2,3 是一个列表。**但是使用Array实现的List的属性与使用Linked List实现的List的属性非常不同** 。

Redis列表通过 **Linked List** 实现。这意味着即使列表中有数百万个元素，也会在常量时间内在列表的头部或尾部添加新元素。使用LPUSH命令将新元素添加到具有十个元素的列表头部的速度与将一个元素添加到具有1000万个元素的列表头部相同。

有什么缺点？在使用Array（常量时间索引访问）实现的列表中，通过索引访问元素非常快，而在链接列表实现的列表中则不是那么快（其中操作需要与所访问元素的索引成比例的工作量）。

Redis列表是使用 **链表** 实现的，因为对于数据库系统而言，能够以非常快的方式将元素添加到很长的列表中是至关重要的。正如您将在片刻中看到的那样，Redis Lists可以在恒定时间内以恒定长度获取。

当快速访问大量元素集合的中间位置很重要时，可以使用不同的数据结构，称为排序集（sorted set）。排序集将在本教程后面介绍。
## Redis列表的第一步
LPUSH命令将新元素添加到左侧（头部）的列表中，而RPUSH命令将新元素添加到右侧（尾部）的列表中。 最后，LRANGE命令从列表中提取元素范围：
```
> rpush mylist A
(integer) 1
> rpush mylist B
(integer) 2
> lpush mylist first
(integer) 3
> lrange mylist 0 -1
1) "first"
2) "A"
3) "B"
```
请注意，LRANGE需要两个索引，即要返回的范围的第一个和最后一个元素。 两个索引都可以是负数，告诉Redis从结尾开始计数：所以-1是最后一个元素，-2是列表的倒数第二个元素，依此类推。

如您所见，RPUSH附加了列表右侧的元素，而最后的LPUSH附加了左侧的元素。

这两个命令都是可变参数命令，这意味着您可以在一次调用中将多个元素自由地推送到列表中：

```
> rpush mylist 1 2 3 4 5 "foo bar"
(integer) 9
> lrange mylist 0 -1
1) "first"
2) "A"
3) "B"
4) "1"
5) "2"
6) "3"
7) "4"
8) "5"
9) "foo bar"
```
Redis列表中定义的一个重要操作是弹出元素的能力。 Popping元素是从列表中检索元素并同时从列表中删除元素的操作。 您可以从左侧和右侧弹出元素，类似于如何在列表的两侧推送元素：
```
> rpush mylist a b c
(integer) 3
> rpop mylist
"c"
> rpop mylist
"b"
> rpop mylist
"a"
```
我们添加了三个元素并弹出了三个元素，因此在这个命令序列的末尾，列表为空，并且没有更多元素可以弹出。 如果我们尝试弹出另一个元素，这就是我们得到的结果：
```
> rpop mylist
(nil)
```
Redis返回NULL值以表示列表中没有元素。
## 列表的常见用例
列表对于许多任务很有用，两个非常有代表性的用例如下：

* 记住用户发布到社交网络的最新更新。
* 进程之间的通信，使用生产者将item推入列表的消费者 - 生产者模式，以及消费者（通常是工人）消费这些item和执行的操作。 Redis具有特殊的列表命令，使这个用例更加可靠和高效。

例如，流行的Ruby库resque和sidekiq都使用Redis列表来实现后台作业。

流行的Twitter社交网络将用户发布的最新推文收录到Redis列表中。

要逐步描述常见用例，请假设您的主页显示在照片共享社交网络中发布的最新照片，并且您希望加快访问速度。

* 每次用户发布新照片时，我们都会将其ID添加到带有LPUSH的列表中。
* 当用户访问主页时，我们使用LRANGE 0 9来获取最新的10个帖子。

## 上限列表
在许多用例中，我们只想使用列表来存储最新的项目，无论它们是什么：社交网络更新，日志或其他任何内容。

Redis允许我们使用列表作为上限集合，只记住最新的N项并使用 **LTRIM** 命令丢弃所有最旧的项。

LTRIM命令类似于LRANGE，但它不是显示指定范围的元素，而是将此范围设置为新列表值。 超出给定范围之外的所有元素。

一个例子将使它更清楚：
```
> rpush mylist 1 2 3 4 5
(integer) 5
> ltrim mylist 0 2
OK
> lrange mylist 0 -1
1) "1"
2) "2"
3) "3"
```
上面的LTRIM命令告诉Redis只从索引0到2中获取列表元素，其他所有内容都将被丢弃。 这允许一个非常简单但有用的模式：一起执行List推操作+ List修剪操作以添加新元素并丢弃超出限制的元素：
```
LPUSH mylist <some element>
LTRIM mylist 0 999
```
上面的组合添加了一个新元素，并且只将1000个最新元素放入列表中。 使用LRANGE，您可以访问top items，而无需记住非常旧的数据。

**注意：虽然LRANGE在技术上是一个O（N）命令，但是向列表的头部或尾部访问小范围是一个恒定时间操作**。

## 列表阻塞操作
列表具有使其适合实现队列的特殊功能，并且通常作为进程间通信系统的构建块：阻塞操作。

想象一下，您希望使用一个流程将item推送到列表中，并使用不同的流程来实际对这些item进行某种工作。 这是通常的生产者/消费者设置，可以通过以下简单方式实现：
* 要将项目推入列表，生产者调用LPUSH。
* 要从列表中提取/处理项目，消费者会调用RPOP。

但是有时候列表可能是空的并且没有任何东西可以处理，所以RPOP只返回NULL。 在这种情况下，消费者被迫等待一段时间并再次使用RPOP重试。 这称为 **轮询** ，在这种情况下不是一个好主意，因为它有几个缺点：

1. 强制Redis和客户端处理无用命令（当列表为空时所有请求都不会完成实际工作，它们只会返回NULL）。
2. 为item处理添加延迟，因为在工作程序收到NULL之后，它会等待一段时间。 为了使延迟更小，我们可以在对RPOP的呼叫之间等待更少，从而放大问题1的效果，即对Redis的无用呼叫。

所以Redis实现了名为BRPOP和BLPOP的命令，它们是RPOP和LPOP的版本，如果列表为空则能够阻塞：只有当新元素添加到列表中时，或者当用户指定的超时时，它们才会返回调用者。

这是我们可以在worker中使用的BRPOP调用的示例：
```
> brpop tasks 5
1) "tasks"
2) "do_something"
```
这意味着：“等待列表任务中的元素，但是如果5秒后没有元素可用则返回”。

请注意，您可以使用0作为超时来永久等待元素，并且您还可以指定多个列表而不仅仅是一个，以便同时在多个列表上等待，并在第一个列表收到元素时收到通知。

关于BRPOP的一些注意事项：

1. 客户端以有序的方式等待服务：阻塞列表的第一个客户端首先获得服务，以此类推。
2. 与RPOP相比，返回值是不同的：它是一个双元素数组，它还包含键的名称，因为BRPOP和BLPOP能够阻止等待来自多个列表的元素。
3. 如果达到超时，则返回NULL。

关于列表和阻止操作，您应该了解更多内容。 我们建议您阅读以下内容：

* 可以使用RPOPLPUSH构建更安全的队列或轮换队列。
* 还有一个阻塞命令的变体，称为BRPOPLPUSH。

***brpop: block rpop***

# 自动创建和删除key
到目前为止，在我们的示例中，我们从不必在推送元素之前创建空列表，或者在内部不再包含元素时删除空列表。 Redis负责在列表为空时删除键，或者如果键不存在并且我们尝试向其添加元素，例如，使用LPUSH则创建空列表。

这不是特定于列表，它适用于由多个元素组成的所有Redis数据类型 - 集合，排序集和散列。

基本上我们可以用三个规则来概括行为：

1. 当我们向聚合数据类型添加元素时，如果目标键不存在，则在添加元素之前会创建空聚合数据类型。
2. 当我们从聚合数据类型中删除元素时，如果值保持为空，则会自动销毁该键。
3. 使用空键调用LLEN（返回列表长度）等只读命令或删除元素的写命令总是产生相同的结果，就好像键持有类型的空聚合类型一样 命令期望找到。

规则1的例子：
```
> del mylist
(integer) 1
> lpush mylist 1 2 3
(integer) 3
```
但是，如果key存在，我们无法对错误的类型执行操作：
```
> set foo bar
OK
> lpush foo 1 2 3
(error) WRONGTYPE Operation against a key holding the wrong kind of value
> type foo
string
```
规则2的示例：
```
> lpush mylist 1 2 3
(integer) 3
> exists mylist
(integer) 1
> lpop mylist
"3"
> lpop mylist
"2"
> lpop mylist
"1"
> exists mylist
(integer) 0
```
弹出所有元素后，键不再存在。

规则3的例子：
```
> del mylist
(integer) 0
> llen mylist
(integer) 0
> lpop mylist
(nil)
```
# Redis Hashes
Redis哈希看起来正是人们可能期望使用字段值对来查看“哈希”：
```
> hmset user:1000 username antirez birthyear 1977 verified 1
OK
> hget user:1000 username
"antirez"
> hget user:1000 birthyear
"1977"
> hgetall user:1000
1) "username"
2) "antirez"
3) "birthyear"
4) "1977"
5) "verified"
6) "1"
```
虽然散列很方便表示对象，但实际上可以放入散列中的字段数没有实际限制（除了可用内存），因此您可以在应用程序中以多种不同方式使用散列。

命令HMSET设置哈希的多个字段，而HGET检索单个字段。 HMGET类似于HGET，但返回一组值：

```
> hmget user:1000 username birthyear no-such-field
1) "antirez"
2) "1977"
3) (nil)
```
还有一些命令能够对各个字段执行操作，例如HINCRBY：

```
> hincrby user:1000 birthyear 10
(integer) 1987
> hincrby user:1000 birthyear 10
(integer) 1997
```
您可以在文档中找到哈希命令的完整列表。

值得注意的是，小哈希（即，具有小值的少数元素）以特殊方式编码在存储器中，使得它们非常有效地存储。

# Redis Sets
Redis集是字符串的无序集合。 SADD命令将新元素添加到集合中。 也可以针对集合执行许多其他操作，例如测试给定元素是否已存在，执行多个集合之间的交集，并集或差异等等。

```
> sadd myset 1 2 3
(integer) 3
> smembers myset
1. 3
2. 1
3. 2
```
在这里，我已经为我的集合添加了三个元素，并告诉Redis返回所有元素。 如您所见，它们没有排序 - Redis可以在每次调用时以任意顺序返回元素，因为没有与用户签订元素排序的合同。

Redis有命令来测试成员属性。 例如，检查元素是否存在：
```
> sismember myset 3
(integer) 1
> sismember myset 30
(integer) 0
```
“3”是该组的成员，而“30”不是。

集合适用于表示对象之间的关系。 例如，我们可以轻松使用集合来实现标签。

对此问题进行建模的一种简单方法是为我们要标记的每个对象设置一个集合。 该集包含与该对象关联的标记的ID。

一个例子是标记新闻文章。 如果文章ID 1000标记有标记1,2,5和77，则集合可以将这些标记ID与新闻项相关联：
```
> sadd news:1000:tags 1 2 5 77
(integer) 4
```
我们也可能想要反向关系：用给定标签标记的所有新闻的列表：
```
> sadd tag:1:news 1000
(integer) 1
> sadd tag:2:news 1000
(integer) 1
> sadd tag:5:news 1000
(integer) 1
> sadd tag:77:news 1000
(integer) 1
```
获取给定对象的所有标记是微不足道的：
```
> smembers news:1000:tags
1. 5
2. 1
3. 77
4. 2
```
注意：在示例中，我们假设您有另一个数据结构，例如Redis哈希，它将标记ID映射到标记名称。

使用正确的Redis命令仍然可以轻松实现其他非平凡的操作。 例如，我们可能想要一起列出标签1,2,10和27的所有对象的列表。 我们可以使用SINTER命令执行此操作，该命令执行不同组之间的交集。 我们可以用：
```
> sinter tag:1:news tag:2:news tag:10:news tag:27:news
... results here ...
```
除了交集之外，您还可以执行联合，差集，提取随机元素等等。

提取元素的命令称为SPOP，可以方便地模拟某些问题。 例如，为了实现基于网络的扑克游戏，您可能希望用set代表您的套牌。 想象一下，我们使用一个字符前缀（C）lubs，（D）iamonds，（H）earts，（S）pades：

```
>  sadd deck C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 CJ CQ CK
   D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 DJ DQ DK H1 H2 H3
   H4 H5 H6 H7 H8 H9 H10 HJ HQ HK S1 S2 S3 S4 S5 S6
   S7 S8 S9 S10 SJ SQ SK
   (integer) 52
```
现在我们想为每位玩家提供5张牌。 **SPOP命令删除一个随机元素**，将其返回给客户端，因此在这种情况下它是完美的操作。

然而，如果我们直接在我们的牌组中调用它，在下一场比赛中我们将需要再次填充牌组，这可能并不理想。 因此，首先，我们可以将存储在卡片组中的集合的副本复制到game：1：deck。

这是使用SUNIONSTORE完成的，SUNIONSTORE通常执行多个集合之间的并集，并将结果存储到另一个集合中。 但是，由于单个集合的结合本身，我可以复制我的套牌：
```
> sunionstore game:1:deck deck
(integer) 52
```
现在我准备为第一位玩家提供五张牌：
```
> spop game:1:deck
"C6"
> spop game:1:deck
"CQ"
> spop game:1:deck
"D1"
> spop game:1:deck
"CJ"
> spop game:1:deck
"SJ"
```
一对千斤顶，不是很好......

现在是介绍set命令的好时机，该命令提供了一组内的元素数量。 这通常在集合论的上下文中称为集合的基数，因此Redis命令称为SCARD。

```
> scard game:1:deck
(integer) 47
```
数学运算：52 - 5 = 47。

当您需要获取随机元素而不从集合中删除它们时，SRANDMEMBER命令适合该任务。 它还具有返回重复和非重复元素的能力。

# Redis sorted set
排序集是一种数据类型，类似于Set和Hash之间的混合。 与集合一样，有序集合由唯一的，非重复的字符串元素组成，因此在某种意义上，有序集合也是一个集合。

但是，虽然内部集合中的元素没有排序，但是有序集合中的每个元素都与浮点值相关联，称为分数（这就是为什么类型也类似于散列，因为每个元素都映射到一个值）。

此外，排序集合中的元素按顺序排列（因此它们不是根据请求排序的，顺序是用于表示排序集合的数据结构的特性）。 它们按照以下规则排序：

1. 如果A和B是两个具有不同分数的元素，如果A.score是> B.score ，那么A> B。
2. 如果A和B具有完全相同的分数，那么如果A字符串在字典上大于B字符串，则A> B. A和B字符串不能相等，因为有序集只有唯一元素。

让我们从一个简单的例子开始，添加一些选定的黑客名称作为有序集合元素，其出生年份为“得分”。
```
> zadd hackers 1940 "Alan Kay"
(integer) 1
> zadd hackers 1957 "Sophie Wilson"
(integer) 1
> zadd hackers 1953 "Richard Stallman"
(integer) 1
> zadd hackers 1949 "Anita Borg"
(integer) 1
> zadd hackers 1965 "Yukihiro Matsumoto"
(integer) 1
> zadd hackers 1914 "Hedy Lamarr"
(integer) 1
> zadd hackers 1916 "Claude Shannon"
(integer) 1
> zadd hackers 1969 "Linus Torvalds"
(integer) 1
> zadd hackers 1912 "Alan Turing"
(integer) 1
```
正如您所看到的，ZADD与SADD类似，但需要一个额外的参数（放在要添加的元素之前），这是分数。 ZADD也是可变参数，因此您可以自由指定多个得分-值对，即使在上面的示例中未使用它。

对于排序集，返回按出生年份排序的黑客列表是微不足道的，因为实际上它们已经排序了。

实现说明：排序集是通过包含跳过列表和散列表的双端口数据结构实现的，因此每次添加元素时，Redis都会执行O（log（N））操作。 这很好，但是当我们要求排序的元素时，Redis根本不需要做任何工作，它已经全部排序了：

```
> zrange hackers 0 -1
1) "Alan Turing"
2) "Hedy Lamarr"
3) "Claude Shannon"
4) "Alan Kay"
5) "Anita Borg"
6) "Richard Stallman"
7) "Sophie Wilson"
8) "Yukihiro Matsumoto"
9) "Linus Torvalds"
```
注意：0和-1表示从元素索引0到最后一个元素（-1就像在LRANGE命令的情况下一样工作）。

如果我想以相反的方式排序它们，最小到最老的怎么办？ 使用ZREVRANGE而不是ZRANGE：
```
> zrevrange hackers 0 -1
1) "Linus Torvalds"
2) "Yukihiro Matsumoto"
3) "Sophie Wilson"
4) "Richard Stallman"
5) "Anita Borg"
6) "Alan Kay"
7) "Claude Shannon"
8) "Hedy Lamarr"
9) "Alan Turing"
```
使用WITHSCORES参数也可以返回分数：
```
> zrange hackers 0 -1 withscores
1) "Alan Turing"
2) "1912"
3) "Hedy Lamarr"
4) "1914"
5) "Claude Shannon"
6) "1916"
7) "Alan Kay"
8) "1940"
9) "Anita Borg"
10) "1949"
11) "Richard Stallman"
12) "1953"
13) "Sophie Wilson"
14) "1957"
15) "Yukihiro Matsumoto"
16) "1965"
17) "Linus Torvalds"
18) "1969"
```
## Range操作
排序集比这更强大。 他们可以在范围内操作。 让我们得到所有出生到1950年的人。 我们使用ZRANGEBYSCORE命令来执行此操作：
```
> zrangebyscore hackers -inf 1950
1) "Alan Turing"
2) "Hedy Lamarr"
3) "Claude Shannon"
4) "Alan Kay"
5) "Anita Borg"
```
我们要求Redis以负无穷大和1950之间的分数返回所有元素（包括两个极值）。

也可以删除元素范围。 让我们从排序集中删除1940年到1960年间出生的所有黑客：
```
> zremrangebyscore hackers 1940 1960
(integer) 4
```
ZREMRANGEBYSCORE可能不是最好的命令名，但它可能非常有用，并返回已删除元素的数量。

为有序集元素定义的另一个非常有用的操作是get-rank操作。 可以询问有序元素集中元素的位置。

```
> zrank hackers "Anita Borg"
(integer) 4
```
考虑到按降序排序的元素，ZREVRANK命令也可用于获得排名。

# 词典分数
使用Redis 2.8的最新版本，引入了一个新功能，允许按字典顺序获取范围，假设排序集中的元素都插入了相同的相同分数（元素与C memcmp函数进行比较，每个Redis实例都将使用相同的输出进行回复）。

使用词典范围操作的主要命令是ZRANGEBYLEX，ZREVRANGEBYLEX，ZREMRANGEBYLEX和ZLEXCOUNT。

例如，让我们再次添加我们的着名黑客列表，但这次使用所有元素的得分为零：
```
> zadd hackers 0 "Alan Kay" 0 "Sophie Wilson" 0 "Richard Stallman" 0
  "Anita Borg" 0 "Yukihiro Matsumoto" 0 "Hedy Lamarr" 0 "Claude Shannon"
  0 "Linus Torvalds" 0 "Alan Turing"
```
由于排序集排序规则，它们已经按字典顺序排序：

```
> zrange hackers 0 -1
1) "Alan Kay"
2) "Alan Turing"
3) "Anita Borg"
4) "Claude Shannon"
5) "Hedy Lamarr"
6) "Linus Torvalds"
7) "Richard Stallman"
8) "Sophie Wilson"
9) "Yukihiro Matsumoto"
```
使用ZRANGEBYLEX我们可以要求词典范围：
```
> zrangebylex hackers [B [P
1) "Claude Shannon"
2) "Hedy Lamarr"
3) "Linus Torvalds"
```
范围可以是包含的或排他的（取决于第一个字符），字符串无限和负无限分别用+和 - 字符串指定。 有关更多信息，请参阅文档。

此功能很重要，因为它允许我们使用有序集作为通用索引。 例如，如果要通过128位无符号整数参数索引元素，则需要做的就是将元素添加到具有相同分数的排序集中（例如0），但使用由128组成的16字节前缀 big endian中的位数。 由于big endian中的数字按字典顺序排列（以原始字节顺序排列）实际上也是按数字顺序排序的，因此可以在128位空间中请求范围，并获取元素的值以丢弃前缀。

如果您想在更严肃的演示环境中查看该功能，请查看Redis自动完成演示。

[http://autocomplete.redis.io/](http://autocomplete.redis.io/)

# 更新得分：排行榜
在切换到下一个主题之前，关于排序集的最后一个注释。 排序集的分数可以随时更新。 只针对已经包含在已排序集合中的元素调用ZADD将使用O（log（N））时间复杂度更新其得分（和位置）。 因此，当有大量更新时，排序集合是合适的。

由于这个特性，常见的用例是排行榜。 典型的应用程序是一个Facebook游戏，您可以将用户按高分排序，加上排名操作，以显示前N个用户以及排行榜中的用户排名（例如，“ 你是这里＃4932的最佳成绩“）。

# 位图
位图不是实际的数据类型，而是在String类型上定义的一组面向位的操作。 由于字符串是二进制安全blob，并且它们的最大长度为512 MB，因此它们适合设置232个不同的位。

位操作分为两组：恒定时单位(single bit)操作，如将位设置为1或0，或获取其值，以及对位组进行操作，例如计算给定位范围内的设置位数 （例如，人口统计）。

位图的最大优势之一是它们在存储信息时通常可以节省大量空间。 例如，在通过增量用户ID表示不同用户的系统中，可以使用仅512MB的存储器记住40亿用户的单个位信息（例如，知道用户是否想要接收新闻通讯）。

使用SETBIT和GETBIT命令设置和检索位：

```
> setbit key 10 1
(integer) 1
> getbit key 10
(integer) 1
> getbit key 11
(integer) 0
```
SETBIT命令的第一个参数是位号，第二个参数是将该位设置为1或0的值。如果寻址位超出当前字符串长度，命令会自动放大字符串。

GETBIT只返回指定索引处的位值。 超出范围的位（寻址存储在目标密钥中的字符串长度之外的位）始终被认为是零。

有三组命令在一组位上运行：
1. BITOP在不同的字符串之间执行逐位操作。 提供的操作是AND，OR，XOR和NOT。
2. BITCOUNT执行填充计数，报告设置为1的位数。
3. BITPOS查找具有指定值0或1的第一个位。

BITPOS和BITCOUNT都能够以字符串的字节范围运行，而不是在字符串的整个长度上运行。 以下是BITCOUNT调用的一个简单示例：
```
> setbit key 0 1
(integer) 0
> setbit key 100 1
(integer) 0
> bitcount key
(integer) 2
```
位图的常见用例是：

* 各种实时分析。
* 存储与对象ID关联的节省空间但高性能的布尔信息。

例如，想象一下您想知道网站用户每日访问的最长连续性。 您开始计算从零开始的天数，即您将网站公开的日期，并在每次用户访问网站时使用SETBIT设置一些。 作为位索引，您只需获取当前的unix时间，减去初始偏移量，然后除以3600 * 24。

这种方式对于每个用户，您都有一个包含每天访问信息的小字符串。 使用BITCOUNT可以轻松获得给定用户访问网站的天数，同时只需几次BITPOS调用，或者只是获取和分析位图客户端，就可以轻松计算出最长的条纹。

位图很容易分割成多个键，例如为了分片数据集，因为通常最好避免使用大键。 要在不同的key上拆分位图而不是将所有的位都设置为key，一个简单的策略就是每个key存储M位并获得带有 位号/M 的key名称和第N位用于在key内部用位寻址 - 位号MOD M.

# HyperLogLogs
HyperLogLog是用于计算唯一事物的概率数据结构（从技术上讲，这被称为估计集合的基数）。通常计算唯一项目需要使用与您想要计算的项目数量成比例的内存量，因为您需要记住过去已经看过的元素，以避免多次计算它们。然而，有一组算法可以交换内存以获得精确度：以标准错误的估计度量结束，在Redis实现的情况下小于1％。这种算法的神奇之处在于你不再需要使用与计数项目数量成比例的内存量，而是可以使用恒定的内存量！在最坏的情况下12k字节，或者如果您的HyperLogLog（我们从现在开始称它们为HLL）已经看到的元素非常少，则要少得多。

Redis中的HLL虽然在技术上是一种不同的数据结构，但是被编码为Redis字符串，因此您可以调用GET来序列化HLL，并使用SET将其反序列化回服务器。

从概念上讲，HLL API就像使用Sets来执行相同的任务一样。 您可以将每个观察到的元素SADD到一个集合中，并使用SCARD来检查集合中的元素数量，这是唯一的，因为SADD不会重新添加现有元素。

虽然您没有真正将项添加到HLL中，因为数据结构只包含不包含实际元素的状态，所以API是相同的：

* 每次看到新元素时，都会使用PFADD将其添加到计数中。
* 每次要检索到目前为止使用PFADD添加的唯一元素的当前近似值时，都使用PFCOUNT。

```
> pfadd hll a b c d
(integer) 1
> pfcount hll
(integer) 4
```
此数据结构的用例示例是计算用户每天在搜索表单中执行的唯一查询。

Redis还能够执行HLL的联合，请查看完整文档以获取更多信息。

# 其他值得注意的功能
Redis API中还有其他重要的内容无法在本文档的上下文中进行探讨，但值得您关注：

1. 可以递增地迭代大集合的key空间。
2. 可以运行Lua脚本服务器端来改善延迟和带宽。
3. Redis也是Pub-Sub服务器。


# 接下来干什么
[data-type](https://redis.io/topics/data-types-intro)
[DOC](https://redis.io/documentation)
[twitter](https://redis.io/topics/twitter-clone)
[command](https://redis.io/commands#cluster)

