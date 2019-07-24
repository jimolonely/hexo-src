---
title: spring如何返回http状态码
tags:
  - java
  - spring
p: java/051-spring-http-status-code
date: 2019-07-24 08:22:27
---

如何在sring里返回404,400这种状态码？

查看这篇文章提供的3个方法：[https://jaskey.github.io/blog/2014/09/27/how-to-return-404-in-spring-controller/](https://jaskey.github.io/blog/2014/09/27/how-to-return-404-in-spring-controller/)

# 1.自定义异常+@ResponseStatus注解：
```java
 //定义一个自定义异常，抛出时返回状态码404
 @ResponseStatus(value = HttpStatus.NOT_FOUND)
 public class ResourceNotFoundException extends RuntimeException {
     ...
 }

 //在Controller里面直接抛出这个异常
 @Controller
 public class SomeController {
     @RequestMapping(value="/video/{id}",method=RequestMethod.GET)
     public @ResponseBody Video getVidoeById(@PathVariable long id){
         if (isFound()) {
             // 做该做的逻辑
         }
         else {
             throw new ResourceNotFoundException();//把这个异常抛出 
         }
     }
 }
 ```
# 2.使用Spring的内置异常
默认情况下，Spring 的DispatcherServlet注册了DefaultHandlerExceptionResolver,这个resolver会处理标准的Spring MVC异常来表示特定的状态码
```java
  Exception                                   HTTP Status Code
  ConversionNotSupportedException             500 (Internal Server Error)
  HttpMediaTypeNotAcceptableException         406 (Not Acceptable)
  HttpMediaTypeNotSupportedException          415 (Unsupported Media Type)
  HttpMessageNotReadableException             400 (Bad Request)
  HttpMessageNotWritableException             500 (Internal Server Error)
  HttpRequestMethodNotSupportedException      405 (Method Not Allowed)
  MissingServletRequestParameterException     400 (Bad Request)
  NoSuchRequestHandlingMethodException        404 (Not Found)
  TypeMismatchException                       400 (Bad Request)
```
# 3.在Controller方法中通过HttpServletResponse参数直接设值
```java
 //任何一个RequestMapping 的函数都可以接受一个HttpServletResponse类型的参数
 @Controller
 public class SomeController {
     @RequestMapping(value="/video/{id}",method=RequestMethod.GET)
     public @ResponseBody Video getVidoeById(@PathVariable long id ,HttpServletResponse response){
         if (isFound()) {
             // 做该做的逻辑
         }
         else {
             response.setStatus(HttpServletResponse.SC_NOT_FOUND);//设置状态码
         }
         return ....
     }
 }
```


