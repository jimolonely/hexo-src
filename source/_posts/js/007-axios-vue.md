---
title: axios的使用记录
tags:
  - js
  - vue
p: js/007-axios-vue
date: 2019-04-30 13:31:46
---

axios很强大，但有一些踩过的坑。

# 在vue里构造实例

```js
import axios from 'axios';

// Full config:  https://github.com/axios/axios#request-config
// axios.defaults.baseURL = process.env.baseURL || process.env.apiUrl || '';
// axios.defaults.headers.common['Authorization'] = AUTH_TOKEN;
// axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded';

let config = {
    // baseURL: process.env.baseURL || process.env.apiUrl || "",
    withCredentials: true, // Check cross-site Access-Control
    // timeout: 60 * 1000, // Timeout
};

const _axios = axios.create(config);
```

# 设置拦截器

推荐使用：
```js
_axios.interceptors.request.use(
    function (config) {
        // Do something before request is sent
        return config;
    },
    function (error) {
        // Do something with request error
        return Promise.reject(error);
    }
);

// Add a response interceptor
_axios.interceptors.response.use(
    function (response) {
        // Do something with response data
        return response;
    },
    function (error) {
        // Do something with response error
        return Promise.reject(error);
    }
);
```

# application/x-www-form-urlencoded
axios的content-type默认是application/json的，需要修改header才能发送application/x-www-form-urlencoded请求。

```js
    _axios.post(constructUrl(apiType, url), data || {}, {
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }
    }).then(res => {
        handleResult(res.data, callback);
    }).catch(err => {
        handleError(err, errorHandle);
    });
```
但是还没完，axios会把我们传入的data（json对象）序列化为json字符串，这样后台收不到参数。

修改： 使用qs模块序列化， 在request前置拦截器里判断，然后调用`qs.stringify`方法，
把json对象序列化为&连接的键值对参数。

```js
import qs from 'qs';

_axios.interceptors.request.use(
    function (config) {
        config.headers.Authentication = storage.get("TOKEN");
        if (config.data
            && config.headers['Content-Type'] === 'application/x-www-form-urlencoded; charset=UTF-8') {
            config.data = qs.stringify(config.data);
        }
        return config;
    },
    function (error) {
        // Do something with request error
        return Promise.reject(error);
    }
);
```

