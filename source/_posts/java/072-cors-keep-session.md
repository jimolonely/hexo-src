---
title: 前后端分离后如何继续使用session
tags:
  - java
  - springboot
  - cors
p: java/072-cors-keep-session
date: 2019-09-23 16:31:01
---

本文说明前后端分离后如何继续使用session，示例代码使用vue+springboot，但是原理对所有技术栈都适用。

# 0.session的原理

维持前后端状态的东西叫：SESSIONID, 存在cookie里，在分离之前，浏览器会在每次请求时带上这个session id, 服务端实际上将用户信息以key-value形式存储，
key为session id，value为用户信息。

分离之后：

在进行session会话管理的时候，前端无法发送cookie到后端，前端每次访问后端都相当于一次新的会话，这样就导致登录后的信息是无法保存的。客户端每一次访问都需要重新登录。

# 1.前端

在配置中设置`withCredentials: true`:

**当然，因为每个请求都需要加，配置全局的拦截器里比较好**

```js
login() {
  var p = {
    "userName": "xxx",
    "userPassword": "xxx"
  }
  axios.post(this.baseUrl+'/api/auth/login',p,{
    withCredentials: true
}).then(function(res){
      console.log(res);
  });
}
```
或jquery ajax：

```js
$.ajax({
   url: a_cross_domain_url,
   xhrFields: {
      withCredentials: true
   }
});
```

# 2.后端

* 服务端的`Access-Control-Allow-Origin` 不可以设置为`"*"`，必须指定明确的、与请求网页一致的域名(Origin)
* 服务端的 `Access-Control-Allow-Credentials: true`，代表服务器接受Cookie和HTTP认证信息。因为在CORS下，是默认不接受的

在springboot里可以这样：

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        //设置允许跨域的路径
        registry.addMapping("/**")
                //是否允许证书,不再默认开启
                .allowCredentials(true)
                .allowedOrigins("localhost")
                //设置允许的方法
                .allowedMethods("POST", "GET", "PUT", "OPTIONS", "DELETE")
                //跨域允许时间
                .maxAge(3600);
    }
}
```

或者使用基础的HttpServletResponse:

```java
@Override
public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {

    response.setHeader("Access-Control-Allow-Origin", request.getHeader("Origin"));
    response.setHeader("Access-Control-Max-Age", "3600");
    response.addHeader("Access-Control-Allow-Credentials", "true");
}
```

# 3.使用

现在就可以用 `request.getSession()`的经典语句了。

```java
request.getSession().setAttribute("user", userName);

 Object user = request.getSession().getAttribute("user");
```



