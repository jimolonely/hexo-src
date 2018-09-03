---
title: redis批量插入
tags:
  - redis
p: lang/007-redis-mass-insertion
date: 2018-09-03 09:29:01
---

有时，Redis实例需要在很短的时间内加载大量预先存在的或用户生成的数据，以便尽可能快地创建数百万个key。

这称为大量插入，本文档的目标是提供有关如何尽快为Redis提供数据的信息。

{% asset_img 000.png %}

# 使用Luke协议
使用普通的Redis客户端进行大量插入并不是一个好主意，原因有几个：在另一个命令之后发送一个命令的天真方法很慢，因为你必须为每个命令支付往返时间。 可以使用流水线操作，但是为了大量插入许多记录，您需要在同时读取回复时编写新命令，以确保尽可能快地插入。

只有一小部分客户端支持非阻塞I/O，并非所有客户端都能够以有效的方式解析回复以最大化吞吐量。 由于所有这些原因，将数据大量导入Redis的首选方法是以原始格式生成包含Redis协议的文本文件，以便调用插入所需数据所需的命令。

例如，如果我需要生成一个大型数据集，其中表格中有数十亿个键：`keyN - > ValueN'我将创建一个包含Redis协议格式的以下命令的文件：
```
SET Key0 Value0
SET Key1 Value1
...
SET KeyN ValueN
```
创建此文件后，剩下的操作是尽快将其提供给Redis。 在过去，执行此操作的方法是使用netcat和以下命令：

```shell
(cat data.txt; sleep 10) | nc localhost 6379 > /dev/null
```
但是，这不是一种非常可靠的方法来执行批量导入，因为netcat并不真正知道何时传输了所有数据并且无法检查错误。 在2.6或更高版本的Redis中，redis-cli实用程序支持一种称为管道模式的新模式，该模式是为了执行大规模插入而设计的。

使用管道模式运行的命令如下所示：
```
cat data.txt | redis-cli --pipe
```
这将产生类似于此的输出：
```
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 1000000
```
redis-cli实用程序还将确保仅将从Redis实例接收的错误重定向到标准输出。

# 生成Redis协议
Redis协议生成和解析非常简单，并在此处记录。 但是，为了生成大规模插入目标的协议，您不需要了解协议的每个细节，而只需要按以下方式表示每个命令：
```
*<args><cr><lf>
$<len><cr><lf>
<arg0><cr><lf>
<arg1><cr><lf>
...
<argN><cr><lf>
```

其中 `<cr>` 表示“\ r”（或ASCII字符13），`<lf>` 表示“\ n”（或ASCII字符10）。

例如，命令 `SET key value` 由以下协议表示：

```
*3<cr><lf>
$3<cr><lf>
SET<cr><lf>
$3<cr><lf>
key<cr><lf>
$5<cr><lf>
value<cr><lf>
```

或表示为带引号的字符串：
```
"*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$5\r\nvalue\r\n"
```

您需要为大量插入生成的文件只是由以上述方式表示的命令组成，一个接一个。

以下Ruby函数生成有效的协议：
```ruby
def gen_redis_proto(*cmd)
    proto = ""
    proto << "*"+cmd.length.to_s+"\r\n"
    cmd.each{|arg|
        proto << "$"+arg.to_s.bytesize.to_s+"\r\n"
        proto << arg.to_s+"\r\n"
    }
    proto
end

puts gen_redis_proto("SET","mykey","Hello World!").inspect
```
使用上述函数，可以使用以下程序轻松生成上例中的键值对：
```
(0...1000).each{|n|
    STDOUT.write(gen_redis_proto("SET","Key#{n}","Value#{n}"))
}
```
我们可以直接在管道中运行程序到redis-cli，以便执行我们的第一次批量导入会话。

```
$ ruby proto.rb | redis-cli --pipe
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 1000
```
# 管道模式如何工作
在redis-cli的管道模式中需要的魔法是和netcat一样快，并且仍然能够理解服务器同时发送最后一个回复的时间。

这是通过以下方式获得的：

* redis-cli --pipe尝试尽可能快地向服务器发送数据。
* 同时，它在可用时读取数据，尝试解析它。
* 一旦没有更多数据要从stdin读取，它就会发送一个带有随机20字节字符串的特殊ECHO命令：我们确定这是发送的最新命令，如果收到相同的20字节作为批量回复，我们确信我们可以匹配回复检查。
* 一旦发送了这个特殊的最终命令，接收回复的代码就会开始匹配这20个字节的回复。 当达到匹配的回复时，它可以成功退出。

使用这个技巧,为了了解我们发送的命令数量，我们不需要解析我们发送给服务器的协议，只是回复即可。

但是，在解析回复时，我们会对所有已解析的回复进行计数，以便最后我们能够告诉用户大量插入会话传输到服务器的命令数量。


