---
title: java实现LRU算法
tags:
  - java
  - lru
p: algorithm/003-lru-java
date: 2019-05-31 08:50:04
---

本文实现LRU算法，使用自带的LinkedHashMap 和 双链表+HashMap形式实现。

# 使用LinkedHashMap实现
```java
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @author jimo
 * @date 19-5-30 下午8:18
 */
public class LruLinkedHasMap<K, V> extends LinkedHashMap<K, V> {
    private int capacity;

    public LruLinkedHasMap(int capacity) {
        super(16, 0.75f, true);
        this.capacity = capacity;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        System.out.println("removeEldestEntry:(" + eldest.getKey() + "," + eldest.getValue() + ")");
        return size() > capacity;
    }
}
```
测试：
```java
Map<Integer, Integer> lru = new LruLinkedHasMap<>(2);

lru.put(1, 1);
lru.put(2, 2);
System.out.println(lru.get(1));
lru.put(3, 3);
System.out.println(lru.get(2));
System.out.println(lru.get(3));
lru.put(4, 4);
System.out.println(lru.get(1));
System.out.println(lru.get(3));
System.out.println(lru.get(4));
/**
removeEldestEntry:(1,1)
removeEldestEntry:(1,1)
1
removeEldestEntry:(2,2)
null
3
removeEldestEntry:(1,1)
null
3
4
*/
```

# 双链表+HashMap形式实现

```java
package com.jimo.algo.lru;

import java.util.HashMap;
import java.util.Map;

/**
 * 使用双向链表+HashMap实现LRU， get和put都是O(1)复杂度
 *
 * @author jimo
 * @date 19-5-30 下午8:20
 */
public class MyLru<K, V> {

    private int capacity;
    private Node head;
    private Node tail;
    private Map<K, Node> map;

    public MyLru(int capacity) {
        this.capacity = capacity;
        this.map = new HashMap<>(8);
    }

    public void put(K k, V v) {
        // 如果链表为空
        if (head == null) {
            head = new Node(k, v);
            tail = head;
            map.put(k, head);
            return;
        }
        Node node = map.get(k);
        // 如果存在，则提到链表开始, 并更新值
        if (node != null) {
            node.value = v;
            removeToHead(node);
        } else {
            // 否则新建一个节点到开始
            Node newNode = new Node(k, v);
            // 如果长度到了容量，需要去除结尾的节点
            if (map.size() >= capacity) {
                System.out.println("移除末尾节点：[" + tail.key + "," + tail.value + "]");
                map.remove(tail.key);
                tail = tail.prev;
                tail.next = null;
            }
            // 连到开始
            map.put(k, newNode);
            head.prev = newNode;
            newNode.next = head;
            head = newNode;
        }
    }

    /**
     * 访问时，如果缓存有，则返回并把该节点放到最前面
     */
    public V get(K key) {
        Node node = map.get(key);
        if (node == null) {
            return null;
        }
        removeToHead(node);
        return node.value;
    }

    private void removeToHead(Node node) {
        if (node == head) {
            return;
        } else if (node == tail) {
            tail = node.prev;
            tail.next = null;
        } else {
            node.prev.next = node.next;
            node.next.prev = node.prev;
        }
        // set node to head
        node.next = head;
        head.prev = node;
        node.prev = null;
        head = node;
    }

    class Node {
        Node prev;
        Node next;
        K key;
        V value;

        public Node(K key, V value) {
            this.key = key;
            this.value = value;
        }
    }
}
```
测试：
```java
private static void testMyLru() {
    MyLru<Integer, Integer> lru = new MyLru<>(2);
    lru.put(1, 1);
    lru.put(2, 2);
    System.out.println(lru.get(1));
    lru.put(3, 3);
    System.out.println(lru.get(2));
    System.out.println(lru.get(3));
    lru.put(4, 4);
    System.out.println(lru.get(1));
    System.out.println(lru.get(3));
    System.out.println(lru.get(4));
}
/**
1
移除末尾节点：[2,2]
null
3
移除末尾节点：[1,1]
null
3
4
*/
```



参考： [面试挂在了 LRU 缓存算法设计上](https://juejin.im/post/5cedeac1e51d4556bc066eff)

