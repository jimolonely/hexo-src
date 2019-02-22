---
title: java静态代理和动态代理
tags:
  - java
p: java/017-java-static-and-dynamic-proxy
date: 2018-10-17 14:36:23
---

本文以图片为例实现java版本的动静态代理，并分析他们的区别。

# 背景
我们使用一个具有展示功能的图片接口为例，通过代理类实现AOP功能，在展示的前后做一些事情。

# 静态代理
接口：
```java
public interface Image {
	void display(String name);
}
```
实现类：
```java
public class PngImage implements Image {
	@Override
	public void display(String name) {
		System.out.println("展示png图片：" + name);
	}
}

public class JpgImage implements Image {
	@Override
	public void display(String name) {
		System.out.println("展示jpg图片：" + name);
	}
}
```
代理类：
```java
public class ImageProxy implements Image {
	private Image image;

	public ImageProxy(Image image) {
		this.image = image;
	}

	@Override
	public void display(String name) {
		System.out.println("调整下图片大小,美化一下...");
		image.display(name);
		System.out.println("图片资源清理...");
	}
}
```
使用：
```java
final PngImage pngImage = new PngImage();
ImageProxy proxy = new ImageProxy(pngImage);
proxy.display("jimo.png");

final JpgImage jpgImage = new JpgImage();
proxy = new ImageProxy(jpgImage);
proxy.display("jimo.jpg");
```
结果：
```java
调整下图片大小,美化一下...
展示png图片：jimo.png
图片资源清理...
调整下图片大小,美化一下...
展示jpg图片：jimo.jpg
图片资源清理...
```
# 动态代理
新的代理类：
```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class DynamicImageProxy {

	public static void display(String name, Image image) {
		final Image proxiedImage = (Image) Proxy.newProxyInstance(Image.class.getClassLoader(),
				new Class[]{Image.class},
				new ImageProxyHandler(image));
		proxiedImage.display(name);
	}

	private static class ImageProxyHandler implements InvocationHandler {

		private Object image;

		ImageProxyHandler(Object image) {
			this.image = image;
		}

		@Override
		public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
			System.out.println("调整下图片大小,美化一下...");
			final Object invoke = method.invoke(image, args);
			System.out.println("图片资源清理...");
			return invoke;
		}
	}
}
```
需要解释一下Proxy.newProxyInstance()方法：
```java
/*
 返回指定接口的被代理类的实例，该接口将方法调用分派给指定的调用处理程序
 * loader：定义被代理类的class loader
 * interfaces: 被代理类实现的接口，可能不止一个
 * h： 处理程序，处理被代理类，调用其方法，加一些处理
 */
public static Object newProxyInstance(ClassLoader loader,
                      Class<?>[] interfaces,
                      InvocationHandler h)
                               throws IllegalArgumentException
等价于：
Proxy.getProxyClass(loader, interfaces).
         getConstructor(new Class[] { InvocationHandler.class }).
         newInstance(new Object[] { handler });
```

可以看到我们是通过反射来调用对象的方法。

使用：
```java
final PngImage pngImage = new PngImage();
DynamicImageProxy.display("jimo.png", pngImage);

DynamicImageProxy.display("jimo.jpg", new JpgImage());
```
结果当然是一样的：
```java
调整下图片大小,美化一下...
展示png图片：jimo.png
图片资源清理...
调整下图片大小,美化一下...
展示jpg图片：jimo.jpg
图片资源清理...
```

# 动静态代理的区别
静态代理类：由程序员创建或由特定工具自动生成源代码，再对其编译。在程序运行前，代理类的.class文件就已经存在了。
动态代理类：在程序运行时，运用反射机制动态创建而成。
静态代理通常只代理一个类，动态代理是代理一个接口下的多个实现类。
静态代理事先知道要代理的是什么，而动态代理不知道要代理什么东西，只有在运行时才知道。

说明：本文的静态代理并不只针对一个类，而是一个接口，实际上很多场景没有接口，只有一个类，针对每个类都需要写一个代理类。而java里的动态代理使用接口的代理范围更广泛。
# 应用场景
## 1.设计模式里的代理模式
下面是一个简单的例子：

## 2.AOP
比如spring的AOP，或者本文的例子。
## 3.RPC
1. 关于RPC和RESTful接口的区别需要了解下：[参考](https://www.cnblogs.com/jager/p/6519321.html)

[知乎](https://www.zhihu.com/question/41609070)上有一段比较简明：
```
http好比普通话，rpc好比团伙内部黑话。

讲普通话，好处就是谁都听得懂，谁都会讲。

讲黑话，好处是可以更精简、更加保密、更加可定制，坏处就是要求“说”黑话的那一方（client端）也要懂，
而且一旦大家都说一种黑话了，换黑话就困难了。
```

在我们使用Java实现RPC时，会遇到客户端和服务端都要调用同一个接口，所以那个接口应该是公用的。当然，学习和做demo的时候都是放在一个项目里，而项目开发可以提取出一个公共模块，专门存放远程接口，参考[https://blog.csdn.net/gao763024185/article/details/79916406](https://blog.csdn.net/gao763024185/article/details/79916406).

而今天我们关注RPC中的代理模式的使用，大家可以参考以下资料学习完整的RPC：
1. [dubbo](https://github.com/apache/incubator-dubbo)
2. [RPC原理及JAVA实现](https://blog.csdn.net/u011350550/article/details/80582837)
3. [Java实现简单的RPC框架](https://www.cnblogs.com/codingexperience/p/5930752.html)

下面我们省略RPC里的服务端和客户端的网络请求以及注册中心，直接关注代理模块：

项目结构：
{% asset_img 000.png %}

下面是代理类：
```java
public class ClientProxy {
	private static ClientInvoker invoker = new ClientInvoker();

	public static Object getObject(Class<?> clazz) {
		return  Proxy.newProxyInstance(
				clazz.getClassLoader(),
				new Class<?>[]{clazz},
				new InvocationHandler() {
					@Override
					public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
						// 模拟参数
						final Object params = new Object();

						return invoker.invoke(params, "localhost", 8088);
					}
				});
	}
}
```
这样客户端就可以统一请求，获取自己需要的对象了：
```java
final HelloService helloService = (HelloService) ClientProxy.getObject(HelloService.class);
helloService.sayHello();
```
