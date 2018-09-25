---
title: js前端检测用户长时间未操作
tags:
  - js
  - html
p: js/003-front-end-session-check
date: 2018-09-25 17:36:04
---

用在单页面中，前后端分离的情况。

```js
(function () {
    //10min
    const LOGOUT_TIME_LEN = 1000 * 60 * 10;

    let time = new Date().getTime();

    //这里采用鼠标抬起事件，可以换成其他事件
    window.onmouseup = function countTime() {
        time = new Date().getTime();
    };

    //60s检测一次
    const id = window.setInterval(function () {
        if (new Date().getTime() - time > LOGOUT_TIME_LEN) {
            //clear TOKEN
            storage.clear();
            window.clearInterval(id);
            alert("由于您长时间没有操作, session已过期, 请重新登录");
            window.open('/views/login/login.html', '_self');
        }
    }, 1000 * 60);
})();
```
