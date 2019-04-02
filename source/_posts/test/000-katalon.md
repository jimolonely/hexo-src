---
title: katalon实现web UI自动化测试
tags:
  - katalon
  - UI test
p: test/000-katalon
date: 2019-04-02 09:12:03
---

UI测试一直是个难点，但又是自动化不得不迈过去的一道坎。从Selenium到Katalon，也算是一个进步。

# 安装katalon
去[官网](https://www.katalon.com/)注册账号然后下载Katalon Studio即可。直接运行免安装。

# 基本功能
1. Spy元素
2. Record操作

可以参考：[前端自动化测试神器-katalon的基础用法](https://www.fujiabin.com/2018/02/02/%E5%89%8D%E7%AB%AF%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95%E7%A5%9E%E5%99%A8-katalon%E7%9A%84%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95/)

# 基本使用
作为开发人员，当然更擅长编程，katalon使用groovy语言，和java很像。

1. 建立好项目generic

2. 目录结构如下： 我想机智的程序员一眼就能看懂。
    {% asset_img 000.png %}

    ```java
    WebUI.openBrowser(null)
    WebUI.navigateToUrl('http://192.168.1.11/')

    WebUI.setText(findTestObject('login/username'), 'root')
    WebUI.setText(findTestObject('login/password'), '123456')
    WebUI.click(findTestObject('login/btnLogin'))
    ```
3. 运行即可

# 高级使用
[自定义keyword](https://docs.katalon.com/katalon-studio/docs/introduction-to-custom-keywords.html)

[基本语法](https://docs.katalon.com/katalon-studio/tutorials/common_condition_control_statements.html)


参考：
1. [前端自动化测试神器-katalon进阶用法/](https://www.fujiabin.com/2018/02/06/%E5%89%8D%E7%AB%AF%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95%E7%A5%9E%E5%99%A8-katalon%E8%BF%9B%E9%98%B6%E7%94%A8%E6%B3%95/)
2. [https://docs.katalon.com/katalon-studio/docs/getting-started.html](https://docs.katalon.com/katalon-studio/docs/getting-started.html)


