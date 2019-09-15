---
title: ubuntu localhost:ssh:connect to host localhost port 22:Connection refused
tags:
  - linux
  - ubuntu
p: linux/031-ubuntu-ssh-connection-refuesd
date: 2019-09-15 08:37:03
---

localhost: ssh: connect to host localhost port 22: Connection refused.

1. 安装openssh-server：

  ```s
  $ sudo apt-get install openssh-server  
  ```
2. 启动sshd服务
  ```s
  $ sudo service start sshd  
  ```
3. 关闭防火墙，或允许防火墙开放22端口
  ```s
  # 关闭
  $ sudo ufw disable

  # 允许开放22端口
  $ sudo ufw allow 22
  ```
4. 检查：
  ```s
  $ ssh localhost
  The authenticity of host 'localhost (127.0.0.1)' can't be established.
  ECDSA key fingerprint is SHA256:QjfgDMQrMms2YyootfWGBh5rFOWAgTxRHxDyRedmTTg.
  Are you sure you want to continue connecting (yes/no)? yes
  Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
  jack@localhost's password: 
  ```

可以看到，我连自己的机器还需要输入密码，显然不友好，使用ssh-key解决：
```s
# 1.生成ssh key
ssh-keygen -t rsa

# 2.copy到本机
ssh-copy-id localhost
```

