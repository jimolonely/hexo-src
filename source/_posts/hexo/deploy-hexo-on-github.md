---
title: 部署hexo到github
tags:
  - hexo
p: hexo/deploy-hexo-on-github
date: 2017-12-23 22:08:04
---

飞快搭建hexo+github博客.

```shell
# 安装hexo
[jimo@jimo-pc workspace]$ hexo init myblog
[jimo@jimo-pc workspace]$ cd myblog
[jimo@jimo-pc workspace]$ npm install
```
<!--more-->
配置基本信息:_config.yml
```shell
title: 在我的世界
subtitle: 你是谁,从哪里来,为什么你活着?
description: who,where,what
author: Jackpler
language: zh-Hans
...

# 配置git
deploy:
  type: git
  repo: git@github.com:jimolonely/jimolonely.github.io.git
  branch: master
  # message: {{ now('YYYY-MM-DD HH:mm:ss') }} 要上会报错
  name: jimolonely
  email: xxx@foxmail.com
```
配置标签:/scaffolds/post.md
```yml
---
title: {{ title }}
date: {{ date }}
tags:  # 定义了我们所有标签
- java
- hexo
- git
---
```
如何使用标签呢?在每篇文章内定义:
```yml
---
title: Hello World
tags: [hexo] # 多个用逗号隔开
---
```

运行起来看:
```shell
$ hexo server
```
写一篇新文章: 一篇文件名为deploy-hexo-on-github的位于_post/hexo/deploy-hexo-on-github.md的文章
```shell
# hexo new title -p dir
[jimo@jimo-pc myblog]$ hexo new deploy-hexo-on-github -p hexo/deploy-hexo-on-github
```

关键的:部署到github.

需要先安装插件:
```shell
[jimo@jimo-pc myblog]$ npm install hexo-deployer-git --save
```
前提:电脑有github,最好是用SSH链接的,github上也有一个项目.
```shell
$ hexo deploy
```
在更新内容后重新生成再部署:
```shell
$ hexo generate
$ hexo deploy
```
ok.

下面是高级内容.

## 如何在markdown里添加图片:

看官方文档:[https://hexo.io/docs/asset-folders.html](https://hexo.io/docs/asset-folders.html)

如何限制图片大小：https://yoheikoga.github.io/2016/04/05/How-to-put-pictures-and-change-sizes-on-your-Hexo-Blog/

## 如何链接站点内文章
```
{% post_link markdown-learning-by-maxiang 点击这里查看这篇文章 %}
```
或则使用绝对路径(不过不是同一天就不行)
```
[功能介绍](/2016/7/11/title.html#功能介绍)
```

## 如何增加About页面:

看文档:[https://github.com/iissnan/hexo-theme-next/wiki/%E5%88%9B%E5%BB%BA-%22%E5%85%B3%E4%BA%8E%E6%88%91%22-%E9%A1%B5%E9%9D%A2](https://github.com/iissnan/hexo-theme-next/wiki/%E5%88%9B%E5%BB%BA-%22%E5%85%B3%E4%BA%8E%E6%88%91%22-%E9%A1%B5%E9%9D%A2)

## 如何实现首页read more,而不是全部显示出来?

经过查找,大概有几种方式.

1. 直接在文章里加 ` <!--more--> `
2. next主题的可以很容易改:
```
auto_excerpt:
  enable: true
  length: 150
```
3. 修改源代码: 位于/themes/landscape/layout/_partial/article.ejs
参考文章:[https://blog.zthxxx.me/posts/Hexo-Automatic-Add-ReadMore/](https://blog.zthxxx.me/posts/Hexo-Automatic-Add-ReadMore/)

原来:
```ejs
<div class="article-entry" itemprop="articleBody">
      <% if (post.excerpt && index){ %>
        <%- post.excerpt %>
        <% if (theme.excerpt_link){ %>
          <p class="article-more-link">
            <a href="<%- url_for(post.path) %>#more"><%= theme.excerpt_link %></a>
          </p>
        <% } %>
      <% } else { %>
        <%- post.content %>
      <% } %>
</div>
```
现在:
```ejs
<div class="article-entry" itemprop="articleBody">
            <% var show_all_content = true %>
              <% if (index) { %>
                <% if (post.excerpt) { %>
                  <% show_all_content = false %>
                    <p>
                      <%- post.excerpt %>
                    </p>
                    <% } else if (theme.auto_excerpt.enable) { %>
                      <% var br_position = 0 %>
                        <% for (var br_count = 0; br_count < theme.auto_excerpt.lines; br_count++) { %>
                          <% br_position = post.content.indexOf('\n',br_position + 1) %>
                            <% if(br_position < 0) { break } %>
                              <% } %>
                                <% if(br_position > 0) { %>
                                  <% show_all_content = false %>
                                    <p>
                                      <%- post.content.substring(0, br_position + 1) %>
                                        <p>
                                          <% } %>
                                            <% } %>
                                              <% } else { %>
                                                <% if (post.toc) { %>
                                                  <div id="toc" class="toc-article">
                                                    <strong class="toc-title">
                                                      <%= __('article.catalogue') %>
                                                    </strong>
                                                    <%- toc(post.content) %>
                                                  </div>
                                                  <% } %>
                                                    <% } %>
                                                      <% if (show_all_content) { %>
                                                        <%- post.content %>
          </div>
          <% } else { %>
          </div>
    <p class="article-more-link">
      <a href="<%- url_for(post.path) %>#more">
        <%= theme.excerpt_link %>
      </a>
    </p>
    <% } %>
```
然后再在themes下的_config.yml里配置:
```
auto_excerpt:
    enable: true
    lines: 1
```
## 如何添加Google分析统计
在themes下的_config.yml里找到:
google_analytics: 你的ID

## 如何排序文章
一般有2种排序方式:
1. 按修改日期
2. 按创建日期

只需要确定文章头部是否有date字段即可,有就按创建日期:
```shell
---
title: Linux内核
tags:
  - linux
  - linux kernel
p: linux/008-linux-kernel1
# date: 2018-04-27 14:56:37
---
```
配置这个模板的地方在
```shell
/scaffolds/post.md
```

## hexo代码样式

原版采用[highlight.js](http://highlightjs.readthedocs.io/en/latest/css-classes-reference.html)
