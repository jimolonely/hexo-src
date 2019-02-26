---
title: redis设计和原理
tags:
  - redis
p: lang/013-redis-design-principle
date: 2019-02-21 14:01:29
---

本文是《redis设计与实现--黄健宏》一书的读后感和笔记。

# SDS（simple dynamic string）
简单动态字符串： redis自定义的字符串结构：
```c
struct sdshdr {
  // 已经使用的长度
  int len;
  // 未使用的长度
  int free;
  char buf[];
}
```
为什么不使用C语言的字符串字面量的原因：
1. 获取字符串长度复杂度为O(1), 而不是O(N)
2. 杜绝缓冲区溢出： 增加字符串内容而忘记分配合适的长度造成覆盖等
3. 减少修改字符串的内存重分配： 主要采用了2种策略
    1. 空间预分配： 低于1MB长度时，扩展会翻倍，超过1MB时每次多分配1MB
    2. 惰性空间释放： 缩短字符串时并不内存分配，只是修改free的长度
4. 二进制安全： 可以保存除文本外，图像、视频、音频等2进制信息，因为不以`\0`来判断结尾，而是len
5. 兼容部分C语言库函数： sds依然保留`\0`结尾，所以可以重复使用部分字符串函数。

# 链表
list的数据结构

单个节点: 是一个双向链表
```c
typedef struct listNode {
  struct listNode *prev;

  struct listNode *next;

  void *value;
} listNode;
```
list结构：
```c
typedef struct list {
  listNode *head;

  listNode *tail;

  unsigned long len;

  // 几个函数 
  void (*dup)(void *ptr);
  void (*free)(void *ptr);
  void (*match)(void *ptr,void *key);
} list;
```


# dict
保存键值对
## 数据结构
```c
typedef struct dictht {
  // hash entry array
  dictEntry **table;

  // hash table size
  unsigned long size;

  // 用于计算索引值，总是等于size-1
  unsigned long sizemask;

  // used size
  unsigned ling used;
} dictht;
```
下面是dictEntry: 每个entry后面可以跟一串entry， 用于到hash出的索引冲突时。
```c
typedef struct dictEntry {
  void *key;

  // value
  union {
    void *val;
    uint64_t u64;
    int64_t s64;
  }

  // 链表
  struct dictEntry *next;
} dictEntry;
```
下面才是字典的最后封装：
```c
typedef struct dict {
  // 类型特定函数
  dictType *type;

  // 私有数据保存传给特定函数的可选参数
  void *privdata;

  // hash table
  dictht ht[2];

  // rehash index: 当rehash没有进行时值为-1
  int rehashidx;
} dict;
```
1. hash table为什么需要2个？
  因为ht[1]是在rehash时使用的，后面会说
2. rehashidx的作用是啥？
  是一个计数器，标记rehash的进度和是否完成。
3. 绘制出dict的数据结构图

{% asset_img 000.png %}

## hash算法
```c
hash = dict->type->hashFunction(key);

// 看到这里的sizemask的作用了把
index = hash & dict->ht[x].sizemask;
```
这个索引值就是dictEntry数组里的下标。

hash算法： MurmurHash

## 冲突解决
采用链地址法： 采用前插法，在dictEntry形成链表。

## rehash
1. 为什么需要？
  因为一段时间后hash表会变得要么很大，要么很少，为了维持一个负载均衡因子，会有2种可能：扩展和收缩。
2. rehash的步骤？
  1. 分配空间给ht[1]
    1. 扩展： newSize >= used*2
    2. 收缩： newSize >= used
  2. 转移，这是一个渐近的过程，并不是一下就过去了，后面会说
  3. 释放ht[0], 交换ht[1]为ht[0]
3. 什么时候hash表会扩展？
  1. 负载因子： load_factor = ht[0].used / ht[0].size
  2. 当没有BGSAVE或BGREWRITEAOF在执行且负载因子>=1, 不知什么时候会大于1？
  3. 当上述命令在执行，且负载因子>=5，执行时负载因子会变大，因为copy on write技术需要节约内存
4. 什么时候收缩？
  当负载因子 < 0.1

## 渐近式rehash
1. why？
  因为当键值对很大时，一次性转移会暂停服务，需要慢慢来
2. 步骤
  1. 这个过程会同时用到ht[0],ht[1]
  2. 初始rehashidx设为0
  3. 每移动一个key-value，rehashidx++
  4. 直到完成，rehashidx重置为-1
3. 在rehash阶段，CRUD怎么办？
  修改会只在ht[1]上进行， 查询会从ht[0]到ht[1]

