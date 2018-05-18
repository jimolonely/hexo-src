---
title: Flask提供词云API
tags:
  - python
  - flask
  - wordcloud
p: python/002-flask-wordcloud
date: 2018-01-18 11:27:21
---
麻雀虽小,五脏俱全.

# 先看代码
```python
from flask import Flask
from flask_restful import Resource, Api
import requests
from io import BytesIO
import base64
from wordcloud import WordCloud
from flask_cors import CORS

app = Flask(__name__)
api = Api(app)
CORS(app)

base_url = 'http://192.168.1.146:8081'


class HelloWorld(Resource):
    def get(self, stuId):
        text = requests.get(base_url + "/fun/getStuAdviceToTeacher?stuId="+str(stuId)).json()['data']
        return self.student_cloud_imgstr(text)

    def student_cloud_imgstr(self,txt):
        wd = WordCloud(font_path="SimHei.ttf", max_font_size=60, \
                    width=600, height=400).generate(txt)
        b = BytesIO()
        wd.to_image().save(b, "PNG")
        img_str = base64.b64encode(b.getvalue())
        return img_str.decode("ascii")


api.add_resource(HelloWorld, '/fun/<stuId>')

if __name__ == '__main__':
    app.run(debug=True, port=8082, host='0.0.0.0')
```
下面将解释有什么问题.

这是干嘛:是访问服务器获取文本,然后生成词云,并将词云图片转为Base64编码返回回去.
# 1.跨域访问
允许所有跨域
```python
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
```
# 2.允许所有IP
```python
app.run(host='0.0.0.0')
```
# 3.词云如何转Base64
这是python3环境
```python
wd = WordCloud(font_path="SimHei.ttf", max_font_size=60, \
                    width=600, height=400).generate(txt)
b = BytesIO()
wd.to_image().save(b, "PNG")
img_str = base64.b64encode(b.getvalue())
return img_str.decode("ascii")
```
在python2下:
```python
import cStringIO
import base64

b = cStringIO.StringIO()
wc.to_image().save(b, format="PNG")
img_str = base64.b64encode(b.getvalue())
return img_str.decode("ascii")
```
# 4.前端图片解析Base64
```html
<img src="data:image/jpeg;base64,"+img_str/>>
```

{% asset_img 00.jpeg %}