---
title: springboot kafkaTemplate使用
tags:
  - java
  - spring-boot
p: java/036-springboot-kafkatemplate
date: 2019-03-19 14:56:41
---

如果能用spring-boot集成的组件当然是最好的。

[项目地址]()

# maven
```xml
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.3.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>
        </dependency>
    </dependencies>
```
# 配置
[完整配置请点我](https://docs.spring.io/spring-boot/docs/current/reference/html/common-application-properties.html)

```yml
server:
  port: 8088
spring:
  kafka:
    consumer:
      auto-commit-interval: 1000
      group-id: logdowngroup1
      bootstrap-servers: h1:9092,h2:9092,h3:9092
      auto-offset-reset: latest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      properties:
        rebalance:
          backoff:
            ms: 2000
          max:
            retries: 10
    producer:
      bootstrap-servers: h1:9092,h2:9092,h3:9092
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
      acks: all
      retries: 0
      batch-size: 16384
      buffer-memory: 33554432
      properties:
        metadata:
          broker:
            list: h1:9092,h2:9092,h3:9092
        message:
          send:
            max:
              retries: 3
        linger:
          ms: 1
        ssl:
          client:
            auth: required
```
注意，里面properties是其他配置，如果对应的kafka没有这些配置，则不起作用，会打印警告日志：
```java
2019-03-19 14:51:55.616  WARN 20894 --- [nio-8088-exec-3] o.a.k.clients.producer.ProducerConfig    :
 The configuration 'message.send.max.retries' was supplied but isn't a known config.
2019-03-19 14:51:55.617  WARN 20894 --- [nio-8088-exec-3] o.a.k.clients.producer.ProducerConfig    : 
The configuration 'ssl.client.auth' was supplied but isn't a known config.
2019-03-19 14:51:55.617  WARN 20894 --- [nio-8088-exec-3] o.a.k.clients.producer.ProducerConfig    :
 The configuration 'metadata.broker.list' was supplied but isn't a known config.
```

# 代码
生产者：
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Service
public class Producer {
    private static final Logger logger = LoggerFactory.getLogger(Producer.class);
    static final String TOPIC = "users";

    @Resource
    private KafkaTemplate<String, String> kafkaTemplate;

    public void sendMessage(String msg) {
        logger.info(">>>>>------producer msg: [{}]", msg);
        kafkaTemplate.send(TOPIC, msg);
    }
}
```
消费者：
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class Consumer {
    private final static Logger logger = LoggerFactory.getLogger(Consumer.class);

    @KafkaListener(topics = Producer.TOPIC)
    public void consumes(String msg) {
        logger.info("<<<<<------consumer msg:[{}]", msg);
    }
}
```
controller:
```java
@RestController
@RequestMapping("/kafka")
public class KafkaController {
    @Resource
    private Producer producer;

    @GetMapping("/publish")
    public String sendMsg(@RequestParam("msg") String msg) {
        this.producer.sendMessage(msg);
        return "send msg[" + msg + "] success!";
    }
}
```

访问：
```
$ curl http://localhost:8088/kafka/publish?msg=hahah
send msg[hahah] success!
```
log:
```java
2019-03-19 15:08:05.959  INFO 20894 --- [nio-8088-exec-7] com.jimo.kafka.Producer                  
: >>>>>------producer msg: [hahah]
2019-03-19 15:08:06.027  INFO 20894 --- [ntainer#0-0-C-1] com.jimo.kafka.Consumer                  
: <<<<<------consumer msg:[hahah]
```

# 可配置
如果我们想让topic字段可配置，就需要做一点小改变：

[@KafkaListener的topic可以是SpEL表达式](https://github.com/spring-projects/spring-kafka/issues/132),
[或这个](https://github.com/spring-projects/spring-kafka/issues/361)

```java
    @KafkaListener(topics = "${kafka.topic}")
    public void consumes2(String msg) {
        logger.info("<<<<<------consumer2 msg:[{}]", msg);
    }
```
producer同步发送：
```java
    @Value("${kafka.topic}")
    private String topic;

    public boolean sendMsgSync(String key, String msg) {
        logger.info(">>>>>------producer msg: [{}]", msg);

        final boolean[] ok = {true};
        ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, msg);
        ListenableFuture<SendResult<String, String>> future = kafkaTemplate.send(record);
        future.addCallback(new ListenableFutureCallback<SendResult<String, String>>() {
            @Override
            public void onFailure(@NonNull Throwable throwable) {
                logger.error("sent message=[{}] failed!", msg, throwable);
                ok[0] = false;
            }

            @Override
            public void onSuccess(SendResult<String, String> result) {
                logger.info("sent message=[{}] with offset=[{}] success!", msg, result.getRecordMetadata().offset());
            }
        });
        try {
            // 因为是异步发送，所以我们等待，最多10s
            future.get(10, TimeUnit.SECONDS);
        } catch (InterruptedException | ExecutionException | TimeoutException e) {
            logger.error("waiting for kafka send finish failed!", e);
            return false;
        }
        return ok[0];
    }
```
记得配置：
```yml
kafka:
  topic: test
```

[参考文章](https://www.programcreek.com/java-api-examples/index.php?api=org.springframework.kafka.support.SendResult)

