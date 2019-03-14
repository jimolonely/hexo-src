---
title: JSch连接交互式shell+输出流重定向
tags:
  - java
p: java/034-jsch-interactive-shell-stream-redirect
date: 2019-03-14 08:18:42
---

# 引入maven库
```maven
        <dependency>
            <groupId>com.jcraft</groupId>
            <artifactId>jsch</artifactId>
            <version>0.1.55</version>
        </dependency>
```
# 执行单一的命令
过程很简单：
1. 发送一串shell命令
2. 拿回结果

```java
SshInfo ssh = new SshInfo("192.168.x.x", "root", "xxx");
JSch jSch = new JSch();
try {
    Session session = jSch.getSession(ssh.getUsername(), ssh.getHost());
    session.setPassword(ssh.getPassword());
    session.setUserInfo(new MyUserInfo());
    session.connect();

    Channel channel=session.openChannel("exec");
    ((ChannelExec)channel).setCommand("cd / && ls");

    //channel.setInputStream(System.in);
    channel.setInputStream(null);

    //channel.setOutputStream(System.out);

    //FileOutputStream fos=new FileOutputStream("/tmp/stderr");
    //((ChannelExec)channel).setErrStream(fos);
    ((ChannelExec)channel).setErrStream(System.err);

    InputStream in=channel.getInputStream();

    channel.connect();

    byte[] tmp=new byte[1024];
    while(true){
      while(in.available()>0){
        int i=in.read(tmp, 0, 1024);
        if(i<0)break;
        System.out.print(new String(tmp, 0, i));
      }
      if(channel.isClosed()){
        if(in.available()>0) continue; 
        System.out.println("exit-status: "+channel.getExitStatus());
        break;
      }
      try{Thread.sleep(1000);}catch(Exception ee){}
    }
    channel.disconnect();
    session.disconnect();
  } catch (JSchException | IOException e) {
          e.printStackTrace();
}
```
MyUserInfo.java
```java
    class MyUserInfo implements UserInfo {

        @Override
        public String getPassphrase() {
            return null;
        }

        @Override
        public String getPassword() {
            return null;
        }

        @Override
        public boolean promptPassword(String s) {
            return false;
        }

        @Override
        public boolean promptPassphrase(String s) {
            return false;
        }

        @Override
        public boolean promptYesNo(String s) {
            return s.contains("The authenticity of host");
        }

        @Override
        public void showMessage(String s) {

        }
    }
```
上面可以把命令写在一起通过`&&`连接然后一起执行，但不够优雅，如果命令很多就不好排错了。
# 交互式shell
先看一下最后的样子,就和shell一样的：

{% asset_img 000.png %}

代码很简单：
```java
    public void testInteractiveShell() {
        SshInfo ssh = new SshInfo("192.168.64.12", "root", "123456");
        JSch jSch = new JSch();
        try {
            Session session = jSch.getSession(ssh.getUsername(), ssh.getHost());
            session.setPassword(ssh.getPassword());
            session.setUserInfo(new MyUserInfo());
            session.connect();

            Channel exec = session.openChannel("shell");

            exec.setInputStream(System.in, true);
            exec.setOutputStream(System.out);

            exec.connect();
        } catch (JSchException e) {
            e.printStackTrace();
        }
    }
```

# 输入输出流重定向
当然，一般情况我们不会用java构造一个shell来玩，我遇到的情况就是希望能在
同一个shell环境下执行一些命令，而不是每条命令都分开执行，比如：
我先执行`cd /`, 希望下次执行`ls`列出的是根目录的文件，而不是又回到home目录了。

```java
  JSch jSch = new JSch();
  try {
      Session session = jSch.getSession(ssh.getUsername(), ssh.getHost());
      session.setPassword(ssh.getPassword());
      session.setUserInfo(new MyUserInfo());
      session.connect();

      Channel exec = session.openChannel("shell");

      // 输入重定向
      PipedOutputStream pipe = new PipedOutputStream();
      PipedInputStream in = new PipedInputStream(pipe);
      PrintWriter pw = new PrintWriter(pipe);

      exec.setInputStream(in, true);

      // 输出重定向
      PrintStream out = System.out;
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      PrintStream ps = new PrintStream(baos);
      System.setOut(ps);
      exec.setOutputStream(out);

      String[] cmds = {"cd /", "ls", "pwd"};
      for (String cmd : cmds) {
          pw.println(cmd);
      }
      pw.println("exit");
      pw.flush();

      exec.connect();

      // 等待关闭
      while (!exec.isClosed()) {
      }
      // 重定向回来
      System.setOut(out);
      System.out.println(baos.toString());
      
      exec.disconnect();
      session.disconnect();
  } catch (JSchException | IOException e) {
      e.printStackTrace();
  }
```

参考

1. [redirect-console-output-to-string-in-java](https://stackoverflow.com/questions/8708342/redirect-console-output-to-string-in-java)
2. [java-api-examples/index.php?api=com.jcraft.jsch.ChannelShell](https://www.programcreek.com/java-api-examples/index.php?api=com.jcraft.jsch.ChannelShell)
3. [Exec.java](http://www.jcraft.com/jsch/examples/Exec.java.html)


