
# 说明
当换了电脑后,需要以下步骤重建hexo博客环境.

1. 确保有git和node.js环境;
2. clone下这个库; 
3. 安装hexo 
```
$ npm install -g hexo-cli
```
4. 更新包
```
$ npm install
```

# 如何发布到Github Pages?

如果是Linux下，可以直接使用 [submit.sh](./submit.sh).

如果是Windows，那么手动执行命令：

```shell
hexo g
# 要配置git ssh: ssh -T git@github.com
hexo d
```

