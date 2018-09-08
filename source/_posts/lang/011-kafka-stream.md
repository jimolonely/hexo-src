---
title: kafka stream
tags:
  - kafka
p: lang/011-kafka-stream
date: 2018-09-08 14:27:25
---

本文介绍kafka2.0的stream操作，并用java实现调用,实现了官网的3个例子。

# 最简Pipe
pipe相当于管道，连接2个topic的流通道，这里注意的就是消费者的客户端怎么写。

## pipe
管道什么都不做：
```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;

import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class Pipe {
    public static void main(String[] args) {
        final Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "stream-pipe");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG,
                "hadoop4:9092,hadoop5:9092,hadoop6:9092,hadoop7:9092,hadoop8:9092,hadoop9:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        final StreamsBuilder builder = new StreamsBuilder();

        builder.stream("jimo").to("hehe");

        final Topology topology = builder.build();

        final KafkaStreams streams = new KafkaStreams(topology, props);

        final CountDownLatch latch = new CountDownLatch(1);

        // attach shutdown handler to catch control-c
        Runtime.getRuntime().addShutdownHook(new Thread("streams-shutdown-hook") {
            @Override
            public void run() {
                streams.close();
                latch.countDown();
            }
        });

        try {
            streams.start();
            latch.await();
        } catch (Throwable e) {
            System.exit(1);
        }
        System.exit(0);
    }
}
```
## 生产者
生产者依然不变：

```java
    private KafkaProducer<String, String> producer;
    private final String TOPIC = "jimo";

    @Before
    public void init() {
        final Properties properties = new Properties();
        properties.setProperty("metadata.broker.list", "hadoop4:9092,hadoop5:9092,hadoop6:9092,hadoop7:9092,hadoop8:9092,hadoop9:9092");
        properties.setProperty("bootstrap.servers", "hadoop4:9092,hadoop5:9092,hadoop6:9092,hadoop7:9092,hadoop8:9092,hadoop9:9092");
        properties.setProperty("acks", "all");
        properties.setProperty("retries", "0");
        properties.setProperty("batch.size", "16384");
        properties.setProperty("request.timeout.ms", "10000");
        properties.setProperty("message.send.max.retries", "3");
        properties.setProperty("linger.ms", "1");
        properties.setProperty("buffer.memory", "33554432");
        properties.setProperty("ssl.client.auth", "required");
        properties.setProperty("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        properties.setProperty("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        producer = new KafkaProducer<>(properties);

    }

    @Test
    public void sendMessage() throws InterruptedException {
        for (int i = 0; i < 100; i++) {
            ProducerRecord<String, String> record = new ProducerRecord<>(TOPIC, "key" + i, "hehe" + i);
            producer.send(record, (recordMetadata, e) -> {
                System.out.println(recordMetadata.offset());
                if (e != null) {
                    e.printStackTrace();
                }
            });
            Thread.sleep(1000);
        }
    }

    @After
    public void close() {
        producer.close();
    }
}
```
## 消费者

现在到了jimo 的主题里，开启消费者去消费。

java客户端需要改为流的形式：

pom.xml
```
<dependencies>
    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka_2.10</artifactId>
        <version>0.9.0.1</version>
    </dependency>

    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka-clients</artifactId>
        <version>0.9.0.1</version>
    </dependency>
</dependencies>
```
```java
public class StreamConsumer {
    public static void main(String[] args) {
        final Properties properties = new Properties();
        properties.setProperty("bootstrap.servers", "hadoop4:9092,hadoop5:9092,hadoop6:9092,hadoop7:9092,hadoop8:9092,hadoop9:9092");
        properties.setProperty("zookeeper.connect", "hadoop4:2181,hadoop5:2181,hadoop6:2181");
        properties.setProperty("group.id", "stream-pipe");
        properties.setProperty("zookeeper.session.timeout.ms", "5000");
        properties.setProperty("zookeeper.connection.timeout", "10000");
        properties.setProperty("zookeeper.sync.time.ms", "200");
        properties.setProperty("auto.commit.interval.ms", "1000");
        properties.setProperty("rebalance.max.retries", "10");
        properties.setProperty("rebalance.backoff.ms", "2000");
        properties.setProperty("auto.offset.reset", "largest");
        properties.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        properties.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        final ConsumerConnector connector = Consumer.createJavaConsumerConnector(new ConsumerConfig(properties));

        Map<String, Integer> map = new HashMap<>();
        final String topic = "hehe";
        map.put(topic, 1);
        final Map<String, List<KafkaStream<byte[], byte[]>>> streamMap = connector.createMessageStreams(map);

        final KafkaStream<byte[], byte[]> stream = streamMap.get(topic).get(0);

        for (MessageAndMetadata<byte[], byte[]> metadata : stream) {
            System.out.println("------------------offset偏移量:" + metadata.offset());
            System.out.println("-----------------------message:" + Arrays.toString(metadata.message()));
        }
    }
}
```
# LineSplit
出现了个时间戳的问题，
```java
org.apache.kafka.streams.errors.StreamsException: Input record ConsumerRecord(topic = telegraf, partition = 1, offset = 0, CreateTime = -1, serialized key size = -1, serialized value size = 283, headers = RecordHeaders(headers = [], isReadOnly = false)
 has invalid (negative) timestamp。 Use a different TimestampExtractor to process this data.
```

于是重写了生成时间戳的方法：
```java
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.streams.processor.TimestampExtractor;

public class MyEventTimeExtractor implements TimestampExtractor {
    @Override
    public long extract(ConsumerRecord<Object, Object> record, long previousTimestamp) {
        return System.currentTimeMillis();
    }
}
```

使用：
```java
properties.put(StreamsConfig.DEFAULT_TIMESTAMP_EXTRACTOR_CLASS_CONFIG, MyEventTimeExtractor.class.getName());
producer = new KafkaProducer<>(properties);
```

这样写出的offset就是随机的了，不是原来的递增？

## 生产者
生产者稍微改下：
```java
ProducerRecord<String, String> record = new ProducerRecord<>(TOPIC, "key" + i, "hehe helo aska cdd" + i);
```

## LineSplit
```java
public class LineSplit {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "streams-line-split");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop4:9092,hadoop5:9092,hadoop6:9092,hadoop7:9092,hadoop8:9092,hadoop9:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        final StreamsBuilder builder = new StreamsBuilder();

        KStream<String, String> source = builder.stream("test");
        source.flatMapValues(value -> Arrays.asList(value.split("\\W+")))
                .to("jimo");

        final Topology topology = builder.build();
        final KafkaStreams streams = new KafkaStreams(topology, props);
        final CountDownLatch latch = new CountDownLatch(1);

        // attach shutdown handler to catch control-c
        Runtime.getRuntime().addShutdownHook(new Thread("streams-shutdown-hook") {
            @Override
            public void run() {
                streams.close();
                latch.countDown();
            }
        });

        try {
            streams.start();
            latch.await();
        } catch (Throwable e) {
            System.exit(1);
        }
        System.exit(0);
    }
}
```
## 消费者
消费者只需修改group.id
```java
properties.setProperty("group.id", "streams-line-split");
```

{% asset_img 000.png %}

# Word Count
没什么问题，注意解析结果时要转成数字。

## 生产者
生产者改了下数据：
```java
final Random r = new Random();
for (int i = 0; i < 100; i++) {
    ProducerRecord<String, String> record = new ProducerRecord<>(TOPIC,
            "key" + i,
            "hehe" + r.nextInt(20) + " helo" + r.nextInt(20)
                    + " aska" + r.nextInt(20) + " cdd" + r.nextInt(20));
    producer.send(record, (recordMetadata, e) -> {
        System.out.println(recordMetadata.offset());
        if (e != null) {
            e.printStackTrace();
        }
    });
    Thread.sleep(1000);
}
```
## WordCount
```java
final StreamsBuilder builder = new StreamsBuilder();
final KStream<String, String> stream = builder.stream("test");
stream.flatMapValues(value -> Arrays.asList(value.toLowerCase(Locale.getDefault()).split("\\W+")))
        .groupBy((key, value) -> value)
        .count(Materialized.as("count"))
        .toStream()
        .to("jimo", Produced.with(Serdes.String(), Serdes.Long()));
```

## 消费者
```java
properties.setProperty("group.id", "streams-wordcount");
...
...
final KafkaStream<byte[], byte[]> stream = streamMap.get(topic).get(0);

/*注意：这个例子返回的key-value是 String-Long型的*/
for (MessageAndMetadata<byte[], byte[]> metadata : stream) {
    System.out.format("-------------offset偏移量:%s,Key:%s,value:%d %n",
            metadata.offset(), new String(metadata.key(), StandardCharsets.UTF_8),
            new BigInteger(metadata.message()).intValue()
    );
}
```

{% asset_img 001.png %}

# 参考

[https://kafka.apache.org/20/documentation/streams/quickstart](https://kafka.apache.org/20/documentation/streams/quickstart)

[https://kafka.apache.org/20/documentation/streams/tutorial](https://kafka.apache.org/20/documentation/streams/tutorial)

