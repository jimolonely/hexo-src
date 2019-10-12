---
title: 在docker中运行jupyterhub
tags:
  - jupyterhub
  - docker
p: cloudcompute/022-jupyterhub-in-docker
date: 2019-10-12 10:36:05
---

根绝官方提供的jupyterhub的docker镜像：https://hub.docker.com/r/jupyterhub/jupyterhub/dockerfile，我们有2种选择：

依据dockerfile自定义一个
在这个基础的镜像上增加jupyterhub_config.py配置
我们2个都试试。

自定义jupyterhub docker镜像
因为我们使用的验证方式和spawner都不是默认的，所以安装相应的包：

FROM ubuntu:18.04
LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"
# install nodejs, utf8 locale, set CDN because default httpredir is unreliable
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && \
apt-get -y upgrade && \
apt-get -y install wget git bzip2 && \
apt-get purge && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8
# install Python + NodeJS with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O /tmp/miniconda.sh && \
echo 'e1045ee415162f944b6aebfe560b8fee */tmp/miniconda.sh' | md5sum -c - && \
bash /tmp/miniconda.sh -f -b -p /opt/conda && \
/opt/conda/bin/conda install --yes -c conda-forge \
python=3.6 sqlalchemy tornado jinja2 traitlets requests pip pycurl \
nodejs configurable-http-proxy && \
/opt/conda/bin/pip install --upgrade pip && \
rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH
ADD . /src/jupyterhub
WORKDIR /src/jupyterhub
RUN pip install . && \
rm -rf $PWD ~/.cache ~/.npm && \
pip install dockerspawner && \
pip install jupyterhub-jwtauthenticator
RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
EXPOSE 8000
LABEL org.jupyter.service="jupyterhub"
CMD ["jupyterhub"]
还可以把配置直接放进去，但是映射到外部目录更方便修改。

自定义配置
如果只是自定义配置，那么需要将/srv/jupyterhub目录映射到宿主机，用于存放配置文件和其他数据。

这样，启动容器时就像下面：

docker run --name jupyterhub -v /home/jimo/hub_data:/srv/jupyterhub -p 8000:8000 -p 8081:8081 jupyterhub/jupyterhub:1.0

如果需要安装软件，直接进容器里安装：

docker exec -it 名字 bash

常见问题


参考官方issue

https://github.com/jupyterhub/dockerspawner/issues/210

https://github.com/jupyterhub/dockerspawner/issues/253



因为涉及到运行在docker中的jupyterhub再派生运行在docker中的notebook时好像是嵌套了，这是需要绑定docker.sock

-v /var/run/docker.sock:/var/run/docker.sock

如果遇到jupyterhub和notebook容器不能通信，那么需要让他们处于同一个网络：

--network 共享网络

