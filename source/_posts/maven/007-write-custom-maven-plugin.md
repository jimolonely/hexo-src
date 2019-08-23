---
title: 自己写maven插件
tags:
  - java
  - maven
p: maven/007-write-custom-maven-plugin
date: 2019-08-23 16:44:30
---

本文仿制一个统计代码行数的简单插件，以此理解maven插件的工作原理。

# 1.建一个maven项目
注意： `maven-xxx-plugin`的格式是官方预留的， 我们使用的格式是`xxx-maven-plugin`

```s
$ mvn archetype:generate
Define value for property 'groupId': com.jimo
Define value for property 'artifactId': jcount-maven-plugin
Define value for property 'version' 1.0-SNAPSHOT: : 1.0
Define value for property 'package' com.jimo: : com.jimo
Confirm properties configuration:
groupId: com.jimo
artifactId: jcount-maven-plugin
version: 1.0
package: com.jimo
```

# 2.修改pom文件

1. `packaging`方式
2. 增加`maven-plugin-api`依赖

```xml
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.jimo</groupId>
    <artifactId>jcount-maven-plugin</artifactId>
    <version>1.0</version>
    <name>count-maven-plugin</name>
    <url>http://maven.apache.org</url>

    <packaging>maven-plugin</packaging>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>

        <dependency>
            <groupId>org.apache.maven</groupId>
            <artifactId>maven-plugin-api</artifactId>
            <version>3.5.0</version>
        </dependency>
    </dependencies>
```

# 3.编写核心AbstractMojo实现类

```java
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * goal是必须的
 *
 * @author jimo
 * @date 19-8-23 下午4:10
 * @goal count
 */
public class CountMojo extends AbstractMojo {

    private static final String[] INCLUDES_DEFAULT = {"java", "xml"};

    /**
     * @parameter property="project.basedir"
     * @required
     * @readonly
     */
    private File baseDir;

    /**
     * @parameter property="project.build.sourceDirectory"
     * @required
     * @readonly
     */
    private File sourceDirectory;

    /**
     * @parameter property="project.build.testSourceDirectory"
     * @required
     * @readonly
     */
    private File testSourceDirectory;

    /**
     * @parameter property="project.build.resources"
     * @required
     * @readonly
     */
    private List<Resource> resources;

    /**
     * @parameter property="project.build.testResources"
     * @required
     * @readonly
     */
    private List<Resource> testResources;

    /**
     * 参数：包含哪些格式的文件被统计
     *
     * @parameter
     */
    private String[] includes;

    public void execute() throws MojoExecutionException, MojoFailureException {
        if (includes == null || includes.length == 0) {
            includes = INCLUDES_DEFAULT;
        }

        countDir(sourceDirectory);

        countDir(testSourceDirectory);

        for (Resource resource : resources) {
            countDir(new File(resource.getDirectory()));
        }

        for (Resource testResource : testResources) {
            countDir(new File(testResource.getDirectory()));
        }
    }

    private void countDir(File dir) {
        if (!dir.exists()) {
            return;
        }
        List<File> files = new ArrayList<File>();
        countFiles(files, dir);

        int lines = 0;

        for (File file : files) {
            lines += countLine(file);
        }

        String path = dir.getAbsolutePath().substring(baseDir.getAbsolutePath().length());

        getLog().info(path + ":" + lines + " lines of code in " + files.size() + " files");
    }

    private int countLine(File file) {
        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));
            int line = 0;
            while (reader.ready()) {
                reader.readLine();
                line++;
            }
            return line;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void countFiles(List<File> files, File f) {
        if (f.isFile()) {
            for (String include : includes) {
                if (f.getName().endsWith("." + include)) {
                    files.add(f);
                    break;
                }
            }
        } else {
            for (File file : f.listFiles()) {
                countFiles(files, file);
            }
        }
    }

}
```
注意：关于注释中的变量

* 以前的写法是：` @parameter expression="${property}"`, 
* 现在的写法： `@parameter property="property"`

# 4.安装插件到本地仓库

```s
$ mvn clean install
```

# 5.使用

在另外的项目中使用插件：
```s
  <plugins>
      <plugin>
          <groupId>com.jimo</groupId>
          <artifactId>jcount-maven-plugin</artifactId>
          <version>1.0</version>
          <configuration>
              <includes>
                  <include>java</include>
                  <include>yml</include>
              </includes>
          </configuration>
      </plugin>
  </plugins>
```

可能的结果：
```s
$ mvn com.jimo:jcount-maven-plugin:1.0:count
...
[INFO] --- jcount-maven-plugin:1.0:count (default-cli) @ jasypt-demo ---
[INFO] /src/main/java:18 lines of code in 1 files
[INFO] /src/test/java:22 lines of code in 1 files
[INFO] /src/main/resources:3 lines of code in 1 files
[INFO] /src/main/resources:3 lines of code in 1 files
...
```

参考书籍《maven实战》

