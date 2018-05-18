---
title: 爬取个人微博
tags:
  - python
  - 爬虫
p: python/003-py-weibo
date: 2018-01-31 10:03:05
---
本文将讲解如何爬取微博,并将内容生成词云.

# 爬取准备
1. 使用Google Chrome浏览器,将Agent调成手机客户端,方法如下:

F12-->setting-->More Tools-->Network conditions,把User Agent换成手机.

{% asset_img 000.png %}

{% asset_img 001.png %}

2. 登录微博.

3. 得到要爬取者的uid: https://m.weibo.cn/u/xxxxxxxxxxxxxx

4. 在访问主页时得到访问的cookie,复制Cookie.

{% asset_img 002.png %}

# 爬取代码
将网页分页保存起来,等会解析.
```python
# -*-coding:utf8-*-

import requests
from lxml import etree

user_id = xxxx

cookie = {
    "Cookie": "_T_WM=xxx; SCF=xxx.; SUB=xxx; SUHB=xxx; WEIBOCN_FROM=xxx; M_WEIBOCN_PARAMS=xxx"}
url = 'http://weibo.cn/u/%d?filter=1&page=1' % user_id

html = requests.get(url, cookies=cookie).content
selector = etree.HTML(html)
pageNum = (int)(selector.xpath('//input[@name="mp"]')[0].attrib['value'])

print(u'爬虫准备就绪...')

pages = []
for page in range(1, pageNum + 1):
    # 获取lxml页面
    url = 'http://weibo.cn/u/%d?filter=1&page=%d' % (user_id, page)
    lxml = requests.get(url, cookies=cookie).content

    pages.append(lxml.decode(encoding='utf-8'))
    print("下载完成第%d页" % page)

dir_path = "/home/jimo/workspace/temp/python/love/"

with open("%s%s" % (dir_path, user_id), "w") as f:
    for page in pages:
        f.write(page)
        f.write("\n")
    print(u'微博文字爬取完毕')
```
# 解析代码
{% asset_img 003.png %}

注意对于中文,词云要指定支持中文的字体.
```python
from lxml import etree
from wordcloud import WordCloud
import matplotlib.pyplot as plt

path = "/home/jimo/workspace/temp/python/love/"


def analyze(line):
    '''解析html'''
    html = etree.HTML(line.encode(encoding='utf-8'))
    # 解析微博内容
    contents = html.xpath('//span[@class="ctt"]')
    content = " ".join([c.xpath("string(.)") for c in contents])
    # for c in contents:
    #     text = c.xpath("string(.)")
    #     print(text)

    # 解析发的时间和来自哪里
    times = html.xpath('//span[@class="ct"]')
    time = []
    fromWhere = []
    for t in times:
        text = t.xpath("string(.)")
        splitIndex = text.index("来自")
        time.append(text[:splitIndex - 1])
        fromWhere.append(text[splitIndex:])

    return content, " ".join(time), " ".join(fromWhere)


def generate_word_cloud(content):
    '''生成词云'''
    wc = WordCloud(font_path="SimHei.ttf", max_font_size=60, min_font_size=10, width=1000, height=800).generate(content)
    plt.figure()
    plt.imshow(wc, interpolation="bilinear")
    plt.axis("off")
    plt.show()


with open(path + "1786727217", 'r') as f:
    lines = f.readlines()
    contents, times, fromWhere = [], [], []
    for line in lines:
        c, t, f = analyze(line)
        contents.append(c)
        times.append(t)
        fromWhere.append(f)
    generate_word_cloud(" ".join(contents))
    generate_word_cloud(" ".join(fromWhere))
```
My Love:

{% asset_img 004.png %}
