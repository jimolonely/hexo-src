---
title: 命令行的QQ
tags:
  - linux
p: linux/011-linux-terminal-qq
---
买了服务器,运行一个后台进程,定时给一个好友发消息.

# 使用的库
[Mojo-WebQQ](https://github.com/sjdy521/Mojo-Webqq).
安装好了就ok.

# 我使用python
由于我不是perler,就用python访问其链接吧.
下面保存为chat.pl
```perl
#!/usr/bin/env perl
use Mojo::Webqq;
my ($host,$port,$post_api);

$host = "0.0.0.0"; #发送消息接口监听地址，没有特殊需要请不要修改
$port = 5000;      #发送消息接口监听端口，修改为自己希望监听的端口
#$post_api = 'http://xxxx';  #接收到的消息上报接口，如果不需要接收消息上报，可以删除或注释此行

my $client = Mojo::Webqq->new();
$client->load("ShowMsg");
$client->load("Openqq",data=>{listen=>[{host=>$host,port=>$port}], post_api=>$post_api});
$client->run();
```
然后放在后台运行:
```shell
nohup perl chat.pl >>log.log 2>&1 &
```
# 如何在linux下扫二维码
并不显示在终端,而是提供个服务,远程打开:在/tmp
```shell
# python 2
python -m SimpleHTTPServer 80
# python 3
python -m http.server 80
```
# 写程序
send.py
```python
# coding:utf-8
import requests
from bs4 import BeautifulSoup
import json
import argparse

PATH = 'ids.txt'
'''
先读取文件,不要发以前发过的
'''


def load_dump_obj(path):
    ids = set()
    try:
        with open(path, 'r') as f:
            ids = set(json.load(f))
    except:
        pass
    return ids


def dump_file(path, obj):
    with open(path, 'w') as f:
        json.dump(list(obj), f)


headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'
}


def get_id():
    url = "http://127.0.0.1:5000/openqq/get_friend_info"
    friends = requests.get(url, headers=headers)
    for f in json.loads(friends.text):
        if f['name'] == '孤独的寂寞': # 注意比较中文需要转为utf8
            return f['id']
    return ''


def get_content():
    '''
    获取一些有意思的话发送
    '''
    ids = load_dump_obj(PATH)
    yu_url = "http://www.59xihuan.cn/jingdianyulu_8_1.html"

    page = requests.get(yu_url, headers=headers)

    bs = BeautifulSoup(page.text, "html.parser")
    contents = bs.find_all(name='div', attrs={'class': 'pic_text1'})
    # print(contents)
    sentences = '又过了一天,很高兴我们还在'
    for txt in contents:
        id = txt['id']
        if id not in ids:
            sentences = txt.get_text().strip()
            ids.add(id)
            dump_file(PATH, ids)
            break
    # print(sentences)
    print sentences
    return sentences


def send_msg(id, content):
    url = 'http://127.0.0.1:5000/openqq/send_friend_message'
    data = {
        'id': id,
        'content': content
    }
    response = requests.post(url, data=data, headers=headers)
    # print(response.text)
    print response.text


def arg_parse():
    parser = argparse.ArgumentParser(description="发送QQ信息")
    parser.add_argument('id', help="qq friend id")
    return parser.parse_args()


if __name__ == '__main__':
    # try:
    #     # arg = arg_parse()
    #     id = get_id()
    #     content = get_content()
    #     send_msg(id, content)
    # except:
    #     print("寂寞的发射了错误.....................")
        # get_content()
    id = get_id()
    content = get_content()
    send_msg(id, content)
```
send2.py是爬取百科的内容:
```python
# coding:utf-8
import requests
from bs4 import BeautifulSoup
import json
import argparse

OLD_IDS_PATH = 'old_ids.txt'
LEMMA_PATH = 'lemmas.txt'

'''
先读取文件,不要发以前发过的
'''


def load_dump_obj(path):
    ids = None
    try:
        with open(path, 'r') as f:
            ids = json.load(f)
    except:
        pass
    return ids


def dump_file(path, obj):
    with open(path, 'w') as f:
        json.dump(obj, f)


headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'
}


def get_id():
    url = "http://127.0.0.1:5000/openqq/get_friend_info"
    friends = requests.get(url, headers=headers)
    friends.encoding = 'utf-8'
    for f in json.loads(friends.text):
        # if f['name'] == '孤独的寂寞'.decode('utf-8'): # python 2.x
        if f['name'] == '孤独的寂寞':  # python3
            return f['id']
    return ''


def get_content():
    '''
    获取baike
    '''
    lemmas = load_dump_obj(LEMMA_PATH)
    if not lemmas or len(lemmas) == 0:
        yu_url = "https://baike.baidu.com/wikitag/api/getlemmas"
        data = {
            'limit': 3500,
            'timeout': 3000,
            'tagId': 76613,
            'fromLemma': False,
            'contentLength': 40,
            'page': 0
        }
        lemmas = requests.post(yu_url, headers=headers, data=data).json()
        print(lemmas)
        dump_file(LEMMA_PATH, lemmas)
    ids = load_dump_obj(OLD_IDS_PATH)
    if ids is None:
        ids = []
    curr_lemma = None
    for lemma in lemmas['lemmaList']:
        if lemma['lemmaId'] not in ids:
            curr_lemma = lemma
            ids.append(lemma['lemmaId'])
            dump_file(OLD_IDS_PATH, list(ids))
            break

    content = "请收下我诚挚的祝福"
    if not curr_lemma:  # 数据已用完
        return content
    # 开始爬取页面
    url = curr_lemma['lemmaUrl']
    page = requests.get(url, headers=headers)
    page.encoding = 'utf-8'
    # print(page.text)
    bs = BeautifulSoup(page.text, "html.parser")
    summary = bs.find(name="div", attrs={"class": "lemma-summary"})
    return curr_lemma['lemmaTitle'] + '\n' + summary.get_text()


def send_msg(id, content):
    url = 'http://127.0.0.1:5000/openqq/send_friend_message'
    data = {
        'id': id,
        'content': content
    }
    response = requests.post(url, data=data, headers=headers)
    # print(response.text)
    # print response.text


def arg_parse():
    parser = argparse.ArgumentParser(description="发送QQ信息")
    parser.add_argument('id', help="qq friend id")
    return parser.parse_args()


if __name__ == '__main__':
    # try:
    #     # arg = arg_parse()
    #     id = get_id()
    #     content = get_content()
    #     send_msg(id, content)
    # except:
    #     print("寂寞的发射了错误.....................")
    # get_content()
    id = get_id()
    content = get_content()
    send_msg(id, content)
```

# 定时运行
编辑位于/etc/crontab的文件
```shell
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

30 23 * * * root python ~/qq/send.py 
0 12 * * * root python ~/qq/send.py
0 6 * * * root python ~/qq/send.py 
```
重启:
```shell
systemctl restart crond
```
