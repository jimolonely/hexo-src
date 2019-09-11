---
title: java创建MD5的多种方式
tags:
  - java
  - spring
  - md5
p: java/065-java-md5
date: 2019-09-11 16:34:01
---

本文记录MD5加密的常见创建方式。

# 原生Java创建

```java
	public static String encrypt(String dataStr) {
		try {
			MessageDigest m = MessageDigest.getInstance("MD5");
			m.update(dataStr.getBytes("UTF8"));
			byte s[] = m.digest();
			String result = "";
			for (int i = 0; i < s.length; i++) {
				result += Integer.toHexString((0x000000FF & s[i]) | 0xFFFFFF00).substring(6);
			}
			return result;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return "";
	}
```
# Spring Util创建

```java
import org.springframework.util.DigestUtils;

String md5 = DigestUtils.md5DigestAsHex(base.getBytes());
```

