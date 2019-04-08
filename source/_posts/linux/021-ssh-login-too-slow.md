---
title: connect to ssh too slow
tags:
  - ssh
  - linux
p: linux/021-ssh-login-too-slow
date: 2019-04-08 15:40:00
---

never fullfill the speed, faster, stronger.

# show the verbose

use `-vvv` option to show which step you stuck.
```shell
$ ssh -vvv root@192.168.100.11
OpenSSH_7.6p1 Ubuntu-4ubuntu0.3, OpenSSL 1.0.2n  7 Dec 2017
debug1: Reading configuration data /home/jack/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
...

debug3: authmethod_is_enabled gssapi-with-mic
debug1: Next authentication method: gssapi-with-mic
...
```
it seems to stuck on the GASSAPI, so no check:.

# slove ways

## 1.GASSAPI
in the target host(192.168.100.11) `/etc/ssh/sshd_config`:
```conf
GSSAPIAuthentication no
```
## 2.UseDNS
```java
useDNS no
```

# restart sshd server
```shell
$ sudo service sshd restart
```

enjoy the fast speed.

[reference](https://superuser.com/questions/166359/why-is-my-ssh-login-slow)


