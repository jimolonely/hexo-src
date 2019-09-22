---
title: springboot interceptor posthandle 添加自定义header
tags:
  - java
  - spring
p: java/070-springboot-interceptor-add-header-pro
date: 2019-09-22 17:00:42
---

今天发现springboot里interceptor的一个问题：

在postHandle方法里设置header不会返回到前端，而在preHandle里设置就可以。

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
            String userInfo = JwtUtil.checkToken(token);

            // 允许返回token在响应头中
            response.setHeader("Access-Control-Expose-Headers", "token");
            response.setHeader("Access-Control-Allow-Headers", "token");
            response.setHeader("token", JwtUtil.getToken(userInfo));
            return true;
        } catch (Exception e) {
            throw new AuthFailException();
        }
    }
}
```



