---
title: 我的redis之路
tags:
  - redis
p: lang/002-redis
date: 2018-03-09 09:07:39
---
这是一条不归路.
# 掌握基本命令
跟着官方的web版练习[Try Redis](http://try.redis.io/)即可,我做的文件{% asset_path try-redis.txt%}

现在应该学会了以下命令和数据结构:
```
set/setnx
incr
del
expire
ttl
(list) lpush/rpush/lrange/lpop/rpop/llen
(set) sadd/srem/sismember/smembers/sunion
(sorted set) zadd/zrange
(hash) hset/hgetall/hmset/hget/hincrby/hdel
```
# 熟悉基本功能

# 了解redis应用场景
1. 缓存(会话缓存或FPC全页缓存)
2. 队列
3. 排行榜/计数榜(得益于其原子递增操作)
4. pub/sub

# 写个应用
利用其发布/订阅功能写个聊天应用.

### 1.安装redis
按照官网[https://redis.io/download](https://redis.io/download)做2分钟搞定.

### 2.来看一下demo
一个客户端发布,另一个订阅

先开订阅者:
```shell
$ ./redis-cli 
127.0.0.1:6379> SUBSCRIBE test-channel
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "test-channel"
3) (integer) 1
```
发布者再发送消息:
```shell
127.0.0.1:6379> PUBLISH test-channel hello
(integer) 1
127.0.0.1:6379> PUBLISH test-channel "how are you"
(integer) 1
```
这时候订阅者会收到消息:
```shell
1) "message"
2) "test-channel"
3) "hello"
1) "message"
2) "test-channel"
3) "how are you"
```
更多可以参考文档[https://redis.io/topics/pubsub](https://redis.io/topics/pubsub).
其最后给出了以一个[ruby写的多人聊天室](https://gist.github.com/pietern/348262),我们要用java来写.

### 3.java版聊天室
关于java操作redis的库有很多,我们使用[Jedis](https://github.com/xetorthio/jedis/).

关于Jedis获取redis实例的操作见:[https://github.com/xetorthio/jedis/wiki/Getting-started](https://github.com/xetorthio/jedis/wiki/Getting-started)
操作发布/订阅见:[https://github.com/xetorthio/jedis/wiki/AdvancedUsage](https://github.com/xetorthio/jedis/wiki/AdvancedUsage)

现在的需求:聊天室是多人的,可以发送接受消息.
分解开来:用户A发送的消息会推送给所有用户,每当有一个用户上线就需要多一个订阅者和发送者.

服务器:
```java
package com.jimo;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class ChatServer {

    private JedisPool pool;
    private PSListener listener;

    ChatServer() {
        pool = new JedisPool(new JedisPoolConfig(), "localhost");
        listener = new PSListener();
    }

    public void stop() {
        pool.close();
    }

    /**
     * 每增加用户就开一个线程防止阻塞
     *
     * @param userName
     */
    public void addUser(String userName) {
        new Thread() {
            @Override
            public void run() {
                JedisPool pool1 = new JedisPool(new JedisPoolConfig(), "localhost");
                try (Jedis jedis = pool1.getResource()) {
                    jedis.psubscribe(listener, "chat*");
                }
            }
        }.start();
    }

    /**
     * 将消息推送给所有用户
     *
     * @param msg
     */
    public void sendMsg(String msg) {
        try (Jedis jedis = pool.getResource()) {
            jedis.publish("chat4", msg);
        }
    }
}
```
测试:
```java
package com.jimo;

public class Test {
    public static void main(String[] args) {
        ChatServer chatServer = new ChatServer();

        chatServer.addUser("chat1");
        chatServer.addUser("chat2");
        chatServer.sendMsg("hello");
        chatServer.sendMsg("xixihaha");


        chatServer.stop();
    }
}
```
Listener:
```java
package com.jimo;

import redis.clients.jedis.JedisPubSub;

public class PSListener extends JedisPubSub {

    public void onMessage(String channel, String message) {
        System.out.println("收到channel[" + channel + "]的消息:" + message);
    }

    public void onPMessage(String pattern, String channel, String message) {
        System.out.println("p收到channel[" + channel + "]的消息:" + message);
    }

    public void onSubscribe(String channel, int subscribedChannels) {
        System.out.println(channel + "被订阅");
    }

    public void onUnsubscribe(String channel, int subscribedChannels) {
    }

    public void onPUnsubscribe(String pattern, int subscribedChannels) {
    }

    public void onPSubscribe(String pattern, int subscribedChannels) {
        System.out.println(subscribedChannels + "被订阅:" + pattern);
    }
}
```
上面的代码是有问题的,自己发送的消息也会被推送回来.

