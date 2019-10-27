---
title: docker stats:查看docker占用资源
tags:
  - docker
p: cloudcompute/023-docker-stats
date: 2019-10-15 09:01:51
---

如何查看docker占用的内存？

第一个想到的方法是
1. 先使用docker ps 查看container id
2. ps -ef | grep id, 获得pid
3. 通过top -p pid或 ps命令查看资源

但是这个麻烦且不直观，docker早就想到了。

# docker stats命令

其使用也非常简单：

```s
# docker stats --help

Usage:	docker stats [OPTIONS] [CONTAINER...]

Display a live stream of container(s) resource usage statistics

Options:
  -a, --all             Show all containers (default shows just running)
      --format string   Pretty-print images using a Go template
      --help            Print usage
      --no-stream       Disable streaming stats and only pull the first result
```

单次查看所有：
```s
# docker stats --no-stream
CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
878d22c70e1d        0.00%               82.36 MiB / 500 MiB   16.47%              48.4 kB / 1.94 MB   111 MB / 0 B        15
66d61ad1f9c4        0.00%               82.34 MiB / 500 MiB   16.47%              57.8 kB / 1.94 MB   81.1 MB / 0 B       15
52ca31344410        0.00%               82.62 MiB / 500 MiB   16.52%              70.2 kB / 1.95 MB   134 MB / 0 B        16
9c479d6edb02        0.00%               89.08 MiB / 500 MiB   17.82%              251 kB / 344 kB     127 MB / 4.1 kB     50
```

格式化输出：

```s
#  docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" --no-stream
NAME                CPU %               MEM USAGE / LIMIT
jupyter-ext4-key    0.00%               82.39 MiB / 500 MiB
jupyter-ext3-key    0.00%               82.37 MiB / 500 MiB
jupyter-ext2-key    0.01%               84.85 MiB / 500 MiB
jupyter-jimo-hehe   0.00%               89.08 MiB / 500 MiB
```




