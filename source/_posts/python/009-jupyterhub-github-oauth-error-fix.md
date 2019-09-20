---
title: jupyterhub接入github认证oauth2.0的问题记录与解决
tags:
  - jupyterhub
  - ubuntu
  - notebook
  - oauth
p: python/009-jupyterhub-github-oauth-error-fix
date: 2019-09-19 20:48:28
---

使用环境：

* ubuntu18.04
* python: 3.6
* jupyterhub:1.0.0

```s
$ pip3 list | grep jupyter
jupyter-client          5.3.3              
jupyter-core            4.5.0              
jupyterhub              1.0.0
```

# tornado.simple_httpclient.HTTPStreamClosedError: Stream closed


```s
[I 2019-09-19 20:43:31.611 JupyterHub oauth2:100] OAuth redirect: 'http://localhost:8000/hub/oauth_callback'
[I 2019-09-19 20:43:31.615 JupyterHub log:174] 302 GET /hub/oauth_login?next= -> https://github.com/login/oauth/authorize?response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fhub%2Foauth_callback&client_id=b65e07b5e5de7471a7f1&state=[secret] (@::1) 4.52ms
[E 2019-09-19 20:43:39.924 JupyterHub web:1788] Uncaught exception GET /hub/oauth_callback?code=f44ca95caf1e0ea417c7&state=eyJzdGF0ZV9pZCI6ICJiNWQ5NTY2ZjJjNWQ0ODMxOTNjYmZiZjcwNTY1Zjc4ZCIsICJuZXh0X3VybCI6ICIifQ%3D%3D (::1)
    HTTPServerRequest(protocol='http', host='localhost:8000', method='GET', uri='/hub/oauth_callback?code=f44ca95caf1e0ea417c7&state=eyJzdGF0ZV9pZCI6ICJiNWQ5NTY2ZjJjNWQ0ODMxOTNjYmZiZjcwNTY1Zjc4ZCIsICJuZXh0X3VybCI6ICIifQ%3D%3D', version='HTTP/1.1', remote_ip='::1')
    Traceback (most recent call last):
      File "/usr/local/lib/python3.6/dist-packages/tornado/web.py", line 1699, in _execute
        result = await result
      File "/usr/local/lib/python3.6/dist-packages/oauthenticator/oauth2.py", line 207, in get
        user = await self.login_user()
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 655, in login_user
        authenticated = await self.authenticate(data)
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/auth.py", line 383, in get_authenticated_user
        authenticated = await maybe_future(self.authenticate(handler, data))
      File "/usr/local/lib/python3.6/dist-packages/oauthenticator/github.py", line 115, in authenticate
        resp = await http_client.fetch(req)
    tornado.simple_httpclient.HTTPStreamClosedError: Stream closed
    
[E 2019-09-19 20:43:39.932 JupyterHub log:166] {
      "X-Forwarded-Host": "localhost:8000",
      "X-Forwarded-Proto": "http",
      "X-Forwarded-Port": "8000",
      "X-Forwarded-For": "::1",
      "Cookie": "_ga=[secret]; _xsrf=[secret]; oauthenticator-state=[secret]",
      "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
      "Accept-Encoding": "gzip, deflate, br",
      "Sec-Fetch-Site": "cross-site",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
      "Sec-Fetch-Mode": "navigate",
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36",
      "Dnt": "1",
      "Upgrade-Insecure-Requests": "1",
      "Connection": "close",
      "Host": "localhost:8000"
    }
[E 2019-09-19 20:43:39.932 JupyterHub log:174] 500 GET /hub/oauth_callback?code=[secret]&state=[secret] (@::1) 902.66ms
```

看这个issue：

[https://github.com/jupyterhub/jupyterhub/issues/2448](https://github.com/jupyterhub/jupyterhub/issues/2448)

卸载tornado 6.x版本：
```s
$ sudo python3 -m pip uninstall tornado
WARNING: The directory '/home/jack/.cache/pip/http' or its parent directory is not owned by the current user and the cache has been disabled. Please check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
Uninstalling tornado-6.0.3:
  Would remove:
    /usr/local/lib/python3.6/dist-packages/tornado-6.0.3.dist-info/*
    /usr/local/lib/python3.6/dist-packages/tornado/*
Proceed (y/n)? y
  Successfully uninstalled tornado-6.0.3
```

安装5.1.1版本：

```s
$ sudo python3 -m pip install tornado==5.1.1
WARNING: The directory '/home/jack/.cache/pip/http' or its parent directory is not owned by the current user and the cache has been disabled. Please check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
WARNING: The directory '/home/jack/.cache/pip' or its parent directory is not owned by the current user and caching wheels has been disabled. check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
Collecting tornado==5.1.1
  Downloading https://files.pythonhosted.org/packages/e6/78/6e7b5af12c12bdf38ca9bfe863fcaf53dc10430a312d0324e76c1e5ca426/tornado-5.1.1.tar.gz (516kB)
     |████████████████████████████████| 522kB 207kB/s 
Building wheels for collected packages: tornado
  Building wheel for tornado (setup.py) ... done
  Created wheel for tornado: filename=tornado-5.1.1-cp36-cp36m-linux_x86_64.whl size=449843 sha256=b4edbb1e0fc62a3492f261537c508c37aa566f5272e5caeb24261c2e047a2e5f
  Stored in directory: /home/jack/.cache/pip/wheels/6d/e1/ce/f4ee2fa420cc6b940123c64992b81047816d0a9fad6b879325
Successfully built tornado
Installing collected packages: tornado
Successfully installed tornado-5.1.1
```

重启服务后，已经可以登录，但是由于没有将github用户名添加进白名单，因此出现403.

```s
[W 2019-09-19 20:54:40.059 JupyterHub auth:426] User 'jimolonely' not in whitelist.
[W 2019-09-19 20:54:40.060 JupyterHub base:670] Failed login for unknown user
```
添加完白名单后。

接着：

```s
ERROR:asyncio:Task exception was never retrieved
future: <Task finished coro=<BaseHandler.spawn_single_user() done, defined at /usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py:697> exception=KeyError("getpwnam(): name not found: 'jimolonely'",)>
Traceback (most recent call last):
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 889, in spawn_single_user
    timedelta(seconds=self.slow_spawn_timeout), finish_spawn_future
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 807, in finish_user_spawn
    await spawn_future
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 642, in spawn
    raise e
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 546, in spawn
    url = await gen.with_timeout(timedelta(seconds=spawner.start_timeout), f)
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/spawner.py", line 1377, in start
    env = self.get_env()
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/spawner.py", line 1326, in get_env
    env = self.user_env(env)
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/spawner.py", line 1313, in user_env
    home = pwd.getpwnam(self.user.name).pw_dir
KeyError: "getpwnam(): name not found: 'jimolonely'"
[E 2019-09-19 20:58:24.051 JupyterHub pages:284] Previous spawn for jimolonely failed: "getpwnam(): name not found: 'jimolonely'"
[E 2019-09-19 20:58:24.052 JupyterHub log:166] {
      "X-Forwarded-Host": "localhost:8000",
      "X-Forwarded-Proto": "http",
      "X-Forwarded-Port": "8000",
      "X-Forwarded-For": "::1",
      "Cookie": "jupyterhub-hub-login=[secret]; _ga=[secret]; _xsrf=[secret]; jupyterhub-session-id=[secret]",
      "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
      "Accept-Encoding": "gzip, deflate, br",
      "Referer": "http://localhost:8000/hub/spawn-pending/jimolonely",
      "Sec-Fetch-Site": "same-origin",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
      "Sec-Fetch-User": "?1",
      "Sec-Fetch-Mode": "navigate",
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36",
      "Dnt": "1",
      "Upgrade-Insecure-Requests": "1",
      "Connection": "close",
      "Host": "localhost:8000"
    }
[E 2019-09-19 20:58:24.052 JupyterHub log:174] 500 GET /hub/spawn-pending/jimolonely (jimolonely@::1) 8.53ms
```

`spawn for jimolonely failed: "getpwnam()`是给这个用户创建notebook实例时失败。

我们新建本地用户：

```s
$ sudo useradd jimolonely

$ sudo passwd jimolonely
输入新的 UNIX 密码： 
重新输入新的 UNIX 密码： 
passwd：已成功更新密码
```

然后又报错了：

```s
ERROR:asyncio:Task exception was never retrieved
future: <Task finished coro=<BaseHandler.spawn_single_user() done, defined at /usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py:697> exception=SubprocessError('Exception occurred in preexec_fn.',)>
Traceback (most recent call last):
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 889, in spawn_single_user
    timedelta(seconds=self.slow_spawn_timeout), finish_spawn_future
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 807, in finish_user_spawn
    await spawn_future
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 642, in spawn
    raise e
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 546, in spawn
    url = await gen.with_timeout(timedelta(seconds=spawner.start_timeout), f)
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/spawner.py", line 1397, in start
    self.proc = Popen(cmd, **popen_kwargs)
  File "/usr/lib/python3.6/subprocess.py", line 729, in __init__
    restore_signals, start_new_session)
  File "/usr/lib/python3.6/subprocess.py", line 1365, in _execute_child
    raise child_exception_type(err_msg)
subprocess.SubprocessError: Exception occurred in preexec_fn.
[E 2019-09-19 21:01:22.325 JupyterHub pages:284] Previous spawn for jimolonely failed: Exception occurred in preexec_fn.
[E 2019-09-19 21:01:22.325 JupyterHub log:166] {
      "X-Forwarded-Host": "localhost:8000",
      "X-Forwarded-Proto": "http",
      "X-Forwarded-Port": "8000",
      "X-Forwarded-For": "::1",
      "Cookie": "jupyterhub-hub-login=[secret]; _ga=[secret]; _xsrf=[secret]; jupyterhub-session-id=[secret]",
      "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
      "Accept-Encoding": "gzip, deflate, br",
      "Referer": "http://localhost:8000/hub/spawn-pending/jimolonely",
      "Sec-Fetch-Site": "same-origin",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
      "Sec-Fetch-User": "?1",
      "Sec-Fetch-Mode": "navigate",
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36",
      "Dnt": "1",
      "Upgrade-Insecure-Requests": "1",
      "Connection": "close",
      "Host": "localhost:8000"
    }
```

发现是权限问题，使用sudo运行：[https://github.com/jupyterhub/jupyterhub/issues/1527](https://github.com/jupyterhub/jupyterhub/issues/1527)

```s
 $ sudo jupyterhub -f jc.py
 ...
 [E 2019-09-19 21:07:26.114 JupyterHub proxy:658] Failed to find proxy ['configurable-http-proxy']
    The proxy can be installed with `npm install -g configurable-http-proxy`.To install `npm`, install nodejs which includes `npm`.If you see an `EACCES` error or permissions error, refer to the `npm` documentation on How To Prevent Permissions Errors.
[C 2019-09-19 21:07:26.114 JupyterHub app:2349] Failed to start proxy
    Traceback (most recent call last):
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/app.py", line 2347, in start
        await self.proxy.start()
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/proxy.py", line 650, in start
        cmd, env=env, start_new_session=True, shell=shell
      File "/usr/lib/python3.6/subprocess.py", line 729, in __init__
        restore_signals, start_new_session)
      File "/usr/lib/python3.6/subprocess.py", line 1364, in _execute_child
        raise child_exception_type(errno_num, err_msg, err_filename)
    FileNotFoundError: [Errno 2] No such file or directory: 'configurable-http-proxy': 'configurable-http-proxy'
```

有报错，既然找不到，就装：
```s
$ sudo npm install -g configurable-http-proxy
/home/jack/.npm-global/bin/configurable-http-proxy -> /home/jack/.npm-global/lib/node_modules/configurable-http-proxy/bin/configurable-http-proxy
/home/jack/.npm-global/lib
└── configurable-http-proxy@4.1.0
```

最后卡在npm上，虽然可以用sudospawner，但是配起来太麻烦，果断换一条路，使用dockerspawner

[https://github.com/jupyterhub/dockerspawner](https://github.com/jupyterhub/dockerspawner)

记得先安装dockerspawner:`python3 -m pip install dockerspawner`

然后配置：
```s
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
```

重启之后，生成docker容器实例超时：

```s
[I 2019-09-19 21:35:36.053 JupyterHub dockerspawner:998] Found existing container jupyter-jimolonely (id: 0fbb352)
[I 2019-09-19 21:35:36.053 JupyterHub dockerspawner:1013] Starting container jupyter-jimolonely (id: 0fbb352)
[I 2019-09-19 21:35:36.979 JupyterHub log:174] 302 GET /hub/spawn/jimolonely -> /hub/spawn-pending/jimolonely (jimolonely@::1) 1019.86ms
[I 2019-09-19 21:35:37.018 JupyterHub pages:303] jimolonely is pending spawn
ERROR:asyncio:Task exception was never retrieved
future: <Task finished coro=<BaseHandler.spawn_single_user() done, defined at /usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py:697> exception=HTTPError()>
Traceback (most recent call last):
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 889, in spawn_single_user
    timedelta(seconds=self.slow_spawn_timeout), finish_spawn_future
tornado.util.TimeoutError: Timeout

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 922, in spawn_single_user
    % (status, spawner._log_name),
tornado.web.HTTPError: HTTP 500: Internal Server Error (Spawner failed to start [status=ExitCode=1, Error='', FinishedAt=2019-09-19T13:35:36.863473516Z]. The logs for jimolonely may contain details.)
[W 2019-09-19 21:36:03.703 JupyterHub user:678] jimolonely's server never showed up at http://127.0.0.1:32769/user/jimolonely/ after 30 seconds. Giving up
[E 2019-09-19 21:36:03.747 JupyterHub gen:974] Exception in Future <Task finished coro=<BaseHandler.spawn_single_user.<locals>.finish_user_spawn() done, defined at /usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py:800> exception=TimeoutError("Server at http://127.0.0.1:32769/user/jimolonely/ didn't respond in 30 seconds",)> after timeout
    Traceback (most recent call last):
      File "/usr/local/lib/python3.6/dist-packages/tornado/gen.py", line 970, in error_callback
        future.result()
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/handlers/base.py", line 807, in finish_user_spawn
        await spawn_future
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 654, in spawn
        await self._wait_up(spawner)
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 701, in _wait_up
        raise e
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/user.py", line 669, in _wait_up
        http=True, timeout=spawner.http_timeout, ssl_context=ssl_context
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/utils.py", line 234, in wait_for_http_server
        timeout=timeout,
      File "/usr/local/lib/python3.6/dist-packages/jupyterhub/utils.py", line 177, in exponential_backoff
        raise TimeoutError(fail_message)
    TimeoutError: Server at http://127.0.0.1:32769/user/jimolonely/ didn't respond in 30 seconds
```

实际上，我在本地能看到docker镜像启动过，但马上就死了：
```s
$ docker ps -a
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS                     PORTS               NAMES
0fbb3529c1d4        jupyterhub/singleuser:1.0   "tini -g -- start-no…"   5 minutes ago       Exited (1) 2 minutes ago                       jupyter-jimolonely
```

查看docker日志发现是因为docker容器内没有我们配的目录：

```s
Executing the command: jupyter notebook --ip=0.0.0.0 --port=8888 --notebook-dir=/home/jack/workspace/temp/notebook/jimolonely
[C 13:43:07.016 NotebookApp] Bad config encountered during initialization:
[C 13:43:07.017 NotebookApp] No such notebook dir: ''/home/jack/workspace/temp/notebook/jimolonely''
```

于是注释掉关于`#c.Spawner.notebook_dir='/home/jack/workspace/temp/notebook/{username}'`的配置, **同时删除旧的实例`docker rm ID`**.

再启动，发现docker容器起来了：

```s
$ docker ps -a
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS                   PORTS                       NAMES
4a45cb7e3cbd        jupyterhub/singleuser:1.0   "tini -g -- start-no…"   7 seconds ago       Up 5 seconds             127.0.0.1:32772->8888/tcp   jupyter-jimolonely
```

但是昙花一现，界面报500了：

```s
500 : Internal Server Error
The error was:

Failed to connect to Hub API at 'http://127.0.0.1:8081/hub/api'.  Is the Hub accessible at this URL (from host: 4a45cb7e3cbd)?  Make sure to set c.JupyterHub.hub_ip to an IP accessible to single-user servers if the servers are not on the same host as the Hub.
```
下面是启动成功又被删除的日志：

```s
[I 2019-09-19 21:44:03.884 JupyterHub pages:303] jimolonely is pending spawn
[I 2019-09-19 21:44:04.417 JupyterHub base:810] User jimolonely took 1.547 seconds to start
[I 2019-09-19 21:44:04.418 JupyterHub proxy:261] Adding user jimolonely to proxy /user/jimolonely/ => http://127.0.0.1:32772
21:44:04.424 [ConfigProxy] info: Adding route /user/jimolonely -> http://127.0.0.1:32772
21:44:04.424 [ConfigProxy] info: Route added /user/jimolonely -> http://127.0.0.1:32772
21:44:04.425 [ConfigProxy] info: 201 POST /api/routes/user/jimolonely 
[I 2019-09-19 21:44:04.427 JupyterHub users:606] Server jimolonely is ready
[I 2019-09-19 21:44:04.429 JupyterHub log:174] 200 GET /hub/api/users/jimolonely/server/progress (jimolonely@::1) 451.21ms
[I 2019-09-19 21:44:06.319 JupyterHub log:174] 302 GET /hub/spawn-pending/jimolonely -> /user/jimolonely/ (jimolonely@::1) 13.14ms
[I 2019-09-19 21:44:06.386 JupyterHub log:174] 302 GET /hub/api/oauth2/authorize?client_id=jupyterhub-user-jimolonely&redirect_uri=%2Fuser%2Fjimolonely%2Foauth_callback&response_type=code&state=[secret] -> /user/jimolonely/oauth_callback?code=[secret]&state=[secret] (jimolonely@::1) 23.41ms
[W 2019-09-19 21:45:03.446 JupyterHub base:962] User jimolonely server stopped, with exit code: ExitCode=1, Error='', FinishedAt=2019-09-19T13:44:50.187356762Z
[I 2019-09-19 21:45:03.446 JupyterHub proxy:281] Removing user jimolonely from proxy (/user/jimolonely/)
21:45:03.451 [ConfigProxy] info: Removing route /user/jimolonely
```

依然是看docker日志： 这个原因很明显，不能访问`http://127.0.0.1:8081/hub/api`，这是hub的API接口，但是在容器里这个`127.0.0.1`是没有的，需要一个外部的IP，也就是运行容器的主机的IP。

```s
$ docker logs 4a45cb7e3cbd
Executing the command: jupyterhub-singleuser --ip=0.0.0.0 --port=8888
[W 2019-09-19 13:44:03.777 SingleUserNotebookApp configurable:168] Config option `open_browser` not recognized by `SingleUserNotebookApp`.  Did you mean `browser`?
[I 2019-09-19 13:44:03.989 SingleUserNotebookApp extension:155] JupyterLab extension loaded from /opt/conda/lib/python3.7/site-packages/jupyterlab
[I 2019-09-19 13:44:03.989 SingleUserNotebookApp extension:156] JupyterLab application directory is /opt/conda/share/jupyter/lab
[I 2019-09-19 13:44:03.992 SingleUserNotebookApp singleuser:561] Starting jupyterhub-singleuser server version 1.0.1dev
[E 2019-09-19 13:44:03.994 SingleUserNotebookApp singleuser:438] Failed to connect to my Hub at http://127.0.0.1:8081/hub/api (attempt 1/5). Is it running?
    Traceback (most recent call last):
      File "/opt/conda/lib/python3.7/site-packages/jupyterhub/singleuser.py", line 432, in check_hub_version
        resp = await client.fetch(self.hub_api_url)
    ConnectionRefusedError: [Errno 111] Connection refused
[I 2019-09-19 13:44:04.415 SingleUserNotebookApp log:174] 302 GET /user/jimolonely/ -> /user/jimolonely/tree? (@172.17.0.1) 2.17ms
[E 2019-09-19 13:44:05.999 SingleUserNotebookApp singleuser:438] Failed to connect to my Hub at http://127.0.0.1:8081/hub/api (attempt 2/5). Is it running?
    Traceback (most recent call last):
      File "/opt/conda/lib/python3.7/site-packages/jupyterhub/singleuser.py", line 432, in check_hub_version
        resp = await client.fetch(self.hub_api_url)
    ConnectionRefusedError: [Errno 111] Connection refused
[I 2019-09-19 13:44:06.333 SingleUserNotebookApp log:174] 302 GET /user/jimolonely/ -> /user/jimolonely/tree? (@::1) 1.94ms
[I 2019-09-19 13:44:06.353 SingleUserNotebookApp log:174] 302 GET /user/jimolonely/tree? -> /hub/api/oauth2/authorize?client_id=jupyterhub-user-jimolonely&redirect_uri=%2Fuser%2Fjimolonely%2Foauth_callback&response_type=code&state=[secret] (@::1) 5.01ms
[E 2019-09-19 13:44:06.396 SingleUserNotebookApp auth:334] Error connecting to http://127.0.0.1:8081/hub/api: HTTPConnectionPool(host='127.0.0.1', port=8081): Max retries exceeded with url: /hub/api/oauth2/token (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f22d11f9320>: Failed to establish a new connection: [Errno 111] Connection refused'))
[W 2019-09-19 13:44:06.396 SingleUserNotebookApp web:1782] 500 GET /user/jimolonely/oauth_callback?code=ugtkAb9qodjKXXkZdJbReF92N2apKR&state=eyJ1dWlkIjogImNmMzE3YTRhZDZkYjRlYjI4ZWNlZjdmY2ZmMjdhNzYxIiwgIm5leHRfdXJsIjogIi91c2VyL2ppbW9sb25lbHkvdHJlZT8ifQ (::1): Failed to connect to Hub API at 'http://127.0.0.1:8081/hub/api'.  Is the Hub accessible at this URL (from host: 4a45cb7e3cbd)?  Make sure to set c.JupyterHub.hub_ip to an IP accessible to single-user servers if the servers are not on the same host as the Hub.
[E 2019-09-19 13:44:06.427 SingleUserNotebookApp web:2991] Could not open static file ''
[E 2019-09-19 13:44:06.428 SingleUserNotebookApp log:166] {
      "X-Forwarded-Host": "localhost:8000",
      "X-Forwarded-Proto": "http",
      "X-Forwarded-Port": "8000",
      "X-Forwarded-For": "::1",
      "Cookie": "jupyterhub-user-jimolonely-oauth-state=[secret]; _ga=[secret]; _xsrf=[secret]; jupyterhub-session-id=[secret]",
      "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
      "Accept-Encoding": "gzip, deflate, br",
      "Referer": "http://localhost:8000/hub/spawn-pending/jimolonely",
      "Sec-Fetch-Site": "same-origin",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
      "Sec-Fetch-Mode": "navigate",
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36",
      "Dnt": "1",
      "Upgrade-Insecure-Requests": "1",
      "Cache-Control": "max-age=0",
      "Connection": "close",
      "Host": "localhost:8000"
    }
[E 2019-09-19 13:44:06.428 SingleUserNotebookApp log:174] 500 GET /user/jimolonely/oauth_callback?code=[secret]&state=[secret] (@::1) 35.80ms
[W 2019-09-19 13:44:06.464 SingleUserNotebookApp log:174] 404 GET /user/jimolonely/static/components/react/react-dom.production.min.js (@::1) 3.72ms
[W 2019-09-19 13:44:06.496 SingleUserNotebookApp log:174] 404 GET /user/jimolonely/static/components/react/react-dom.production.min.js (@::1) 1.49ms
[E 2019-09-19 13:44:10.003 SingleUserNotebookApp singleuser:438] Failed to connect to my Hub at http://127.0.0.1:8081/hub/api (attempt 3/5). Is it running?
    Traceback (most recent call last):
      File "/opt/conda/lib/python3.7/site-packages/jupyterhub/singleuser.py", line 432, in check_hub_version
        resp = await client.fetch(self.hub_api_url)
    ConnectionRefusedError: [Errno 111] Connection refused
[E 2019-09-19 13:44:18.015 SingleUserNotebookApp singleuser:438] Failed to connect to my Hub at http://127.0.0.1:8081/hub/api (attempt 4/5). Is it running?
    Traceback (most recent call last):
      File "/opt/conda/lib/python3.7/site-packages/jupyterhub/singleuser.py", line 432, in check_hub_version
        resp = await client.fetch(self.hub_api_url)
    ConnectionRefusedError: [Errno 111] Connection refused
[E 2019-09-19 13:44:34.028 SingleUserNotebookApp singleuser:438] Failed to connect to my Hub at http://127.0.0.1:8081/hub/api (attempt 5/5). Is it running?
    Traceback (most recent call last):
      File "/opt/conda/lib/python3.7/site-packages/jupyterhub/singleuser.py", line 432, in check_hub_version
        resp = await client.fetch(self.hub_api_url)
    ConnectionRefusedError: [Errno 111] Connection refused
```

通过github上的示例：[https://github.com/jupyterhub/dockerspawner/tree/master/examples/oauth](https://github.com/jupyterhub/dockerspawner/tree/master/examples/oauth)

这里说得很清楚：
```python
# The docker instances need access to the Hub, so the default loopback port doesn't work:
from jupyter_client.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0]
```

可以看下`public_ips()`方法的结果：
```python
>>> from jupyter_client.localinterfaces import public_ips

>>> public_ips()
['192.168.199.249', '172.17.0.1']
```

于是，我们修改完配置后重启，记得，依然要删除旧的容器实例，再次启动，成功了：

```s
[I 2019-09-19 21:59:12.727 JupyterHub log:174] 200 GET /hub/spawn-pending/jimolonely (jimolonely@::1) 10.11ms
[I 2019-09-19 21:59:12.835 JupyterHub log:174] 200 GET /hub/api (@172.17.0.2) 0.50ms
[I 2019-09-19 21:59:12.866 JupyterHub log:174] 200 POST /hub/api/users/jimolonely/activity (jimolonely@172.17.0.2) 15.00ms
[I 2019-09-19 21:59:13.316 JupyterHub base:810] User jimolonely took 1.607 seconds to start
[I 2019-09-19 21:59:13.317 JupyterHub proxy:261] Adding user jimolonely to proxy /user/jimolonely/ => http://127.0.0.1:32774
21:59:13.322 [ConfigProxy] info: Adding route /user/jimolonely -> http://127.0.0.1:32774
21:59:13.323 [ConfigProxy] info: Route added /user/jimolonely -> http://127.0.0.1:32774
21:59:13.323 [ConfigProxy] info: 201 POST /api/routes/user/jimolonely 
[I 2019-09-19 21:59:13.325 JupyterHub users:606] Server jimolonely is ready
[I 2019-09-19 21:59:13.328 JupyterHub log:174] 200 GET /hub/api/users/jimolonely/server/progress (jimolonely@::1) 486.99ms
[I 2019-09-19 21:59:13.368 JupyterHub log:174] 302 GET /hub/spawn-pending/jimolonely -> /user/jimolonely/ (jimolonely@::1) 16.38ms
[I 2019-09-19 21:59:13.449 JupyterHub log:174] 302 GET /hub/api/oauth2/authorize?client_id=jupyterhub-user-jimolonely&redirect_uri=%2Fuser%2Fjimolonely%2Foauth_callback&response_type=code&state=[secret] -> /user/jimolonely/oauth_callback?code=[secret]&state=[secret] (jimolonely@::1) 40.87ms
[I 2019-09-19 21:59:13.511 JupyterHub log:174] 200 POST /hub/api/oauth2/token (jimolonely@172.17.0.2) 44.80ms
```

界面正常

通过docker里的日志可以看到：创建文件的目录
```s
/user/jimolonely/api/contents/test1.ipynb
```

# 完整配置

```python
# The docker instances need access to the Hub, so the default loopback port doesn't work:
from jupyter_client.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0]

from oauthenticator.github import GitHubOAuthenticator
c.JupyterHub.authenticator_class = GitHubOAuthenticator


#c.Spawner.notebook_dir='/home/jack/workspace/temp/notebook/{username}'
c.Authenticator.whitelist = {'hehe','jack','jimolonely'}
c.Authenticator.admin_users = {'hehe'}

c.GitHubOAuthenticator.oauth_callback_url = 'http://localhost:8000/hub/oauth_callback'
c.GitHubOAuthenticator.client_id = 'xxx'
c.GitHubOAuthenticator.client_secret = 'xxxx'

c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
```

# 使用REST API

需要做几步：

1. 获取token：
  * 通过界面
  * 通过命令行: `jupyterhub token <username>`
2. 配置token到配置文件：
  ```python
  c.JupyterHub.api_tokens = {
      'secret-token': 'username',
  }
  ```
3. 使用：
  ```s
  # 1.token是放在header里的，token前面还有个token标识
  # 2.默认API端口是8081，冲突了可以改
  curl -X GET -H "Authorization: token <token>" "http://IP:8081/hub/api/users/"
  ```

# 新增用户

1. 通过jupyter接口增加用户
  * [接口文档](https://jupyterhub.readthedocs.io/en/stable/_static/rest-api/index.html)

2. 再登录

# 动态用户

如果手动设置了白名单配置，那么只有白名单里的用户可以使用，因此去掉白名单声明，启动时可以看到下面的日志：

```s
[I 2019-09-20 09:53:14.707 JupyterHub app:1563] Not using whitelist. Any authenticated user will be allowed.
```
当然，我们也可以自定义认证器：
[https://github.com/jupyterhub/jupyterhub/issues/1012](https://github.com/jupyterhub/jupyterhub/issues/1012)

# 现在的配置

```python
# The docker instances need access to the Hub, so the default loopback port doesn't work:
from jupyter_client.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0]

from oauthenticator.github import GitHubOAuthenticator
c.JupyterHub.authenticator_class = GitHubOAuthenticator


#c.Spawner.notebook_dir='/home/jack/workspace/temp/notebook/{username}'
# c.Authenticator.whitelist = {'hehe','jack','jimolonely'}
# c.Authenticator.admin_users = {'hehe'}

c.JupyterHub.api_tokens = {
    '95d7628d65224032857d7d36805f3324': 'jimolonely',
}

c.GitHubOAuthenticator.oauth_callback_url = 'http://localhost:8000/hub/oauth_callback'
c.GitHubOAuthenticator.client_id = 'xxx'
c.GitHubOAuthenticator.client_secret = 'xxxx'

c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
```

# 自定义notebook镜像

原生镜像：[https://hub.docker.com/r/jupyterhub/singleuser/dockerfile](https://hub.docker.com/r/jupyterhub/singleuser/dockerfile)





