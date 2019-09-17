---
title: java按行读取文件
tags:
  - java
p: java/069-java-read-file-by-line
date: 2019-09-17 20:03:26
---

本文记录java按行读取文件的方式。

# FileReader+BufferedReader

```java
private  List<String> getFromFile(String path) throws Exception {
    FileReader reader = new FileReader(path);
    BufferedReader br = new BufferedReader(reader);
    List<String> data = new ArrayList<>(10);
    String line;
    while ((line = br.readLine()) != null) {
        data.add(line);
    }
    br.close();
    reader.close();
    return data;
}
```

