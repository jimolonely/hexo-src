---
title: android web-dav client
tags:
  - java
  - android
p: android/001-android-webdav-client
date: 2019-07-30 09:18:41
---

在经过一系列尝试之后，终于成功的找到解决了基于web-dav的android客户端。

在之前，我开始寻找基于java的： {% post_link java/055-java-webdav-client java实现web-dav客户端 %}

但是，用在android上却出现了类冲突： [https://github.com/lookfirst/sardine/issues/298](https://github.com/lookfirst/sardine/issues/298)

```java
E/AndroidRuntime: FATAL EXCEPTION: main
    Process: com.mydomain.myapp.app, PID: 8228
    java.lang.NoSuchFieldError: No static field INSTANCE of type Lorg/apache/http/conn/ssl/AllowAllHostnameVerifier; in class Lorg/apache/http/conn/ssl/AllowAllHostnameVerifier; or its superclasses (declaration of 'org.apache.http.conn.ssl.AllowAllHostnameVerifier' appears in /system/framework/framework.jar!classes3.dex)
```

原始是：android自带的jar包里也有：`org.apache.http.conn.ssl.AllowAllHostnameVerifier`类，导致类冲突。

没办法，又不能改android的包，只能从sardine包下手了。

找到了人家修改的基于android的包：

[https://github.com/thegrizzlylabs/sardine-android](https://github.com/thegrizzlylabs/sardine-android)

注意就是：因为是网络请求，需要放在线程里执行。

下面是示例：
```java
private class Test extends AsyncTask<String, Integer, Boolean> {

    @Override
    protected Boolean doInBackground(String... strings) {
        return isRightUserInfo(strings[0], strings[1]);
    }
}

private boolean isRightUserInfo(String name, String pass) {
    try {
        /*Sardine sardine = SardineFactory.begin(name, pass);
        sardine.list(MyConst.CLOUD_DAV_PATH);*/

        Sardine sardine = new OkHttpSardine();
        sardine.setCredentials(name, pass);
        sardine.list(MyConst.CLOUD_DAV_PATH);
        return true;
    } catch (IOException e) {
        e.printStackTrace();
        return false;
    }
}
```
调用：
```java
Test test = new Test();
Boolean ok = false;
try {
    ok = test.execute(name, pass).get();
} catch (ExecutionException e) {
    e.printStackTrace();
} catch (InterruptedException e) {
    e.printStackTrace();
}
```
