---
title: maven手动指定JDK版本
tags:
  - java
  - maven
p: maven/008-maven-define-jdk-version
date: 2019-09-14 10:27:15
---

每次maven的pom改变，idea都会回到默认的JDK1.5，让人很无语，可以通过指定JDK版本来解决。

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>版本</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>
```


