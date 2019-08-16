---
title: 自定义spring-boot starter步骤
tags:
  - java
  - spring-boot
p: java/057-spring-boot-starter-demo
date: 2019-08-16 15:52:45
---

本文从实践的角度出发，实现一个spring-boot的starter依赖包，为理解spring-boot的starter原理做好准备。

应用场景：
假如有一个开源库，为了顺应时代潮流，想方便使用spring-boot的开发者使用，就需要实现一个方便的依赖，让spring-boot自动加载，让用户以spring-boot的方式使用
这个库。这个依赖就是starter依赖。

例如：我们经常使用的中间件：redis、kafka、mybatis等，都有了官方的starter包。

现在，我们使用一个简单的网络工具为例，说明在自定义starter的过程中会遇到的情况和方法。

1. 使用EnableAutoConfiguration实现自动配置注入：spring.factories
2. 增加IDE配置提示

项目结构：

{% asset_img 000.png %}

这是一个多模块工程，位于spring-boot-starter-demo下的两个子模块：

1. app：用来测试
2. spring-boot-starter-tool: 实现starter的工具类模块

下面就是具体步骤。

# 0.maven依赖

spring-boot-starter-tool的依赖如下：

```xml
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.jimo</groupId>
    <artifactId>spring-boot-starter-tool</artifactId>
    <version>0.0.1</version>
    <name>spring-boot-starter-tool</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
        <spring-boot.version>2.1.7.RELEASE</spring-boot.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>${spring-boot.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
```

注意： `spring-boot-configuration-processor`依赖会自动生成`spring-configuration-metadata.json`文件，这是用于IDE提供参数提醒。

参考：[blog](https://blog.csdn.net/hry2015/article/details/78127567)

# 1.写好工具类

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;

/**
 * @author jimo
 * @date 19-8-16 下午3:41
 */
public class NetTool {
    private Logger logger = LoggerFactory.getLogger(NetTool.class);

    private int connectTimeout;
    private String userAgent;

    public NetTool(NetToolProperties properties) {
        connectTimeout = (int) properties.getConnectTimeout().getSeconds();
        userAgent = properties.getUserAgent();
    }

    public String get(String url) {
        StringBuilder result = new StringBuilder();
        BufferedReader in = null;
        try {
            if (!url.startsWith("http://")) {
                url = "http://" + url;
            }
            URL realUrl = new URL(url);
            // 打开和URL之间的连接
            URLConnection connection = realUrl.openConnection();
            // 设置通用的请求属性
            connection.setConnectTimeout(connectTimeout);
            connection.setRequestProperty("accept", "*/*");
            connection.setRequestProperty("connection", "Keep-Alive");
            connection.setRequestProperty("user-agent", userAgent);

            // 建立实际的连接
            connection.connect();
            // 获取所有响应头字段
            connection.getHeaderFields();
            // 定义 BufferedReader输入流来读取URL的响应
            in = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
            String line;
            while ((line = in.readLine()) != null) {
                result.append(line);
            }
        } catch (Exception e) {
            logger.error("send get request fail！" + e);
            return e.toString();
        }
        // 使用finally块来关闭输入流
        finally {
            try {
                if (in != null) {
                    in.close();
                }
            } catch (Exception e2) {
                logger.error("close BufferedReader fail！" + e2);
            }
        }
        return result.toString();
    }
}
```
NetProperties.java
```java
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@ConfigurationProperties(prefix = "jimo.util.net")
public class NetToolProperties {

    /**
     * 连接超时时间,默认5s
     */
    private Duration connectTimeout = Duration.ofSeconds(5);

    private String userAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)";

    public Duration getConnectTimeout() {
        return connectTimeout;
    }

    public void setConnectTimeout(Duration connectTimeout) {
        this.connectTimeout = connectTimeout;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }
}
```
# 2.配置

这一步可以按条件构造Bean或class，参考文档：[boot-features-condition-annotations](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-developing-auto-configuration.html#boot-features-condition-annotations)

```java
import com.jimo.tool.net.NetTool;
import com.jimo.tool.net.NetToolProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties({NetToolProperties.class})
public class ToolConfiguration {

    private final NetToolProperties netToolProperties;

    public ToolConfiguration(NetToolProperties netToolProperties) {
        this.netToolProperties = netToolProperties;
    }

    @Bean
    public NetTool netTool() {
        return new NetTool(netToolProperties);
    }
}
```
# 3.spring.factories
spring-boot会通过这个文件找到哪些配置需要自动注入，其内容如下：

位于：`resources/META-INF/spring.factories`
```s
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
  com.jimo.tool.ToolConfiguration
```

# 3.使用
在app模块的依赖里，只需要引入即可：

```xml
        <dependency>
            <groupId>com.jimo</groupId>
            <artifactId>spring-boot-starter-tool</artifactId>
            <version>0.0.1</version>
        </dependency>
```


```java
@SpringBootApplication
@RestController
public class AppApplication {

    private final NetTool tool;

    public AppApplication(NetTool tool) {
        this.tool = tool;
    }

    public static void main(String[] args) {
        SpringApplication.run(AppApplication.class, args);
    }

    @GetMapping("/get/{url}")
    public String get(@PathVariable String url) {
        return tool.get(url);
    }
}
```

修改配置参数：application.yml, 会发现IDEA会有提示
```yml
jimo:
  util:
    net:
      connect-timeout: 3s
```

关于配置如何会提示，我们可以这么做：

1.打包`spring-boot-starter-tool`: `$ mvn package`
2.打开jar包，结构如图：

{% asset_img 001.png %}

原因就在这个`spring-configuration-metadata.json`文件，其内容如下：

```json
{
  "groups": [
    {
      "name": "jimo.util.net",
      "type": "com.jimo.tool.net.NetToolProperties",
      "sourceType": "com.jimo.tool.net.NetToolProperties"
    }
  ],
  "properties": [
    {
      "name": "jimo.util.net.connect-timeout",
      "type": "java.time.Duration",
      "description": "连接超时时间,默认5s",
      "sourceType": "com.jimo.tool.net.NetToolProperties",
      "defaultValue": "5s"
    },
    {
      "name": "jimo.util.net.user-agent",
      "type": "java.lang.String",
      "sourceType": "com.jimo.tool.net.NetToolProperties",
      "defaultValue": "Mozilla\/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)"
    }
  ],
  "hints": []
}
```

完整的项目代码参考[https://github.com/jimolonely/spring-boot-starter-demo](https://github.com/jimolonely/spring-boot-starter-demo)

到目前为止，我们依然停留在使用层面上，其原理还一窍不通，不过没关系，慢慢来。

# 参考

1. [官方文档](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-developing-auto-configuration.html)
2. [https://www.jianshu.com/p/85460c1d835a](https://www.jianshu.com/p/85460c1d835a)
3. [https://github.com/linux-china/spring-boot-starter-httpclient](https://github.com/linux-china/spring-boot-starter-httpclient)
4. [https://blog.csdn.net/hry2015/article/details/78127567](https://blog.csdn.net/hry2015/article/details/78127567)

