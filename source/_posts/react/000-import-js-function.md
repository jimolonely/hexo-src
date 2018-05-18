---
title: 在React中引入js函数
tags:
  - react
  - javascript
p: react/000-import-js-function
date: 2018-01-21 18:03:38
---
本文将定义一个js文件,里面增加几个函数,然后在react的js文件里引用.

# 文件结构
```shell
[jimo@jimo-pc src]$ tree
.
├── test
│   └── Test.js
└── utils
    └── net.js
```
我们要做的就是在Test.js里引用net.js.

# net.js
net.js里有封装的访问网络函数:注意export
```javascript
import axios from 'axios';
import qs from 'qs'; //对参数转化

// axios.defaults.baseURL = 'http://192.168.1.146:8082';

export function get(url, callback, errorHandler = null) {
    axios.get('http://192.168.1.146:8082' + url
    ).then(function (response) {
        if (response.data.ok === false) {
            console.log(response.data.msg);
            alert("msg:" + response.data.msg);
        } else {
            callback(response);
        }
    }).catch(function (error) {
        if (errorHandler) {
            errorHandler();
        } else {
            console.log(error);
            alert(error);
        }
    })
}

export function post(url, jsonParam, callback, errorHandler = null) {
    axios.post('http://192.168.1.146:8082' + url,
        qs.stringify(jsonParam)
    ).then(function (response) {
        if (response.data.ok === false) {
            console.log(response.data.msg);
            alert("msg:" + response.data.msg);
        } else {
            callback(response);
        }
    }).catch(function (error) {
        if (errorHandler) {
            errorHandler();
        } else {
            console.log(error);
            alert(error);
        }
    })
}
```
# Test.js里引用
```javascript
import * as net from "../utils/net";

class TeaWC extends Component {

    constructor(props) {
        super(props);
        this.state = {
          xx : ''
        }
        this.myFun = this.myFun.bind(this);
    }

    myFun() {
        var t = this;
        net.get(url, function (response) {
            console.log(response)
            //...
        })
    }

    render() {
        return (
            <div>
                ...
            </div>
        )
    }
}
```
或则另一种引用方式:
```javascript
import {get,post} from "../utils/net";

get(url, function (response) {
    console.log(response)
    //...
})
```