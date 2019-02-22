---
title: java创建对象的方式和差别
tags:
  - java
p: java/026-java-create-instance
date: 2019-02-22 16:49:53
---

本文已例子和原理解释4种java创建对象的方式和原理。

在此之前，我们以User类为例：
```java
public class User implements Serializable {
	private String name;

	public User() {
		System.out.println("user default constructor...");
	}

	public User(String name) {
		this.name = name;
		System.out.println("constructor with name...");
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
```


# 1.new
这种方式没什么好说的，主要从JVM的角度来看类的加载机制。
```java
		// 1. new
		User user1 = new User();
```

# 2.反射

下面是2种方式，区别在于第一种（`Class.forName().newInstance()`）只能调用无参构造方法。
```java
		// 2. reflect
		Class<?> cls = Class.forName("com.jimo.ioc.User");
		User user2 = (User) cls.newInstance();
///		User user3 = User.class.newInstance();

		Constructor<?> c1 = cls.getDeclaredConstructor(String.class);
		c1.setAccessible(true);
		User user4 = (User) c1.newInstance("jimo");
```

# 3.clone()

```java

```

# 4.反序列化
注意，我们采用的实现Serializable接口的方式：
```java
		// 4. 序列化/反序列化

		// write
		ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("User.file"));
		out.writeObject(user4);
		out.close();

		// read
		ObjectInputStream in = new ObjectInputStream(new FileInputStream("User.file"));
		User user5 = (User) in.readObject();
		System.out.println(user5.getName());

```

# 参考
1. [Java对象的序列化与反序列化](http://www.importnew.com/17964.html)
2. [Java中创建对象的方式](https://www.jianshu.com/p/4cc036dbef8d)
