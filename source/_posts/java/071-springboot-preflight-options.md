---
title: axios设置请求头不成功,预检请求被拦截
tags:
  - springboot
  - axios
  - cors
p: java/071-springboot-preflight-options
date: 2019-09-23 13:38:02
---

在跨域时，使用axios在header里设置了自定义请求头，但是后台没获取到，因为浏览器端得request header里也没有。

# axios请求代码

```js
axios.get('http://localhost:8080/test',{
  headers : {
      'Authentication': 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ7XCJpZFwiOjEsXCJwYXNzd29yZFwiOlwiM2JmMDY0MThlOTM2NGVmYWJhOTRhZGE5NWFlNzgwOWNcIixcInBob25lXCI6XCIxMTBcIixcInVzZXJuYW1lXCI6XCJqaW1vXCJ9Iiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTY5MjEzODU4LCJleHAiOjE1NjkyMTc0NTh9.ZW5F1h1GpEG1Qo-X4BAqWsKlZPOlCIIwRKV3bAtKUSU'
  }
}).then(function(res){
    console.log(res)
})
```

然而浏览器端没有Authentication这个header。

# 原因

后台是这么写的：

```java
public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // token 验证
        String token = request.getHeader("Authentication");
        if (StringUtils.isEmpty(token)) {
            throw new AuthFailException();
        }
        try {
            // 允许返回token在响应头中
            response.setHeader("Access-Control-Expose-Headers", "token");
            response.setHeader("Access-Control-Allow-Headers", "token");
            response.setHeader("Access-Control-Allow-Origin", request.getHeader("Origin"));

            String userInfo = JwtUtil.checkToken(token);

            response.setHeader("token", JwtUtil.getToken(userInfo));
            return true;
        } catch (Exception e) {
            throw new AuthFailException();
        }
    }
}
```

原因就在于CORS请求会先发一个OPTIONS请求，这个请求是没有Authentication这个header的，所以验证失败，那么只需要允许预检请求就好：

```java
public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 预检请求得放行
        if ("OPTIONS".equals(request.getMethod())) {
            return true;
        }
        // token 验证...
    }
}
```

参考：[https://segmentfault.com/q/1010000012364132](https://segmentfault.com/q/1010000012364132)



