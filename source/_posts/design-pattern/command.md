---
title: command模式实现undo/redo操作
tags:
  - java
  - design-pattern
p: design-pattern/command
date: 2017-12-24 11:48:17
---
本文将实现一个带有undo/redo操作的计算器来理解command模式.

首先看看原先的command类图:

{% asset_img 000.png %}

然后看看我们这个计算器类图:

{% asset_img 001.png %}

下面是代码,简单包懂.

我们有个计算器:
```java
package com.command;

//相当于Receiver,真正做事情的对象
public class Calculator {
    private int a;
    private int b;
    private int result;

    public enum Operation {
        ADD, SUB, MUL, DIV
    }

    private Operation operation;

    public Calculator(int a, int b, Operation operation) {
        this.a = a;
        this.b = b;
        this.operation = operation;
    }

    public void compute() {
        switch (operation) {
            case ADD:
                result = a + b;
                break;
            case SUB:
                result = a - b;
                break;
            case MUL:
                result = a * b;
                break;
            case DIV:
                if (b == 0) {
                    throw new IllegalArgumentException("除数为0");
                }
                result = a / b;
                break;
        }
        System.out.println("计算:" + a + getOp() + b + "=" + result);
    }

    public int getResult() {
        return result;
    }

    @Override
    public String toString() {
        String op = getOp();
        return a + op + b + "=" + result;
    }

    private String getOp() {
        String op = null;
        switch (operation) {
            case ADD:
                op = "+";
                break;
            case SUB:
                op = "-";
                break;
            case MUL:
                op = "*";
                break;
            case DIV:
                op = "/";
                break;
        }
        return op;
    }
}
```
总的命令接口:
```java
public interface Command {
    void execute();//执行或重做

    void undo();//撤销
}
```
具体的命令实现:
```java
package com.command;

public class ComputeCommand implements Command {

    private Calculator calculator;
    private Calculator preCalculator;//上一步的计算,用于回退

    public ComputeCommand(Calculator calculator) {
        this.calculator = calculator;
    }

    @Override
    public void execute() {
        this.preCalculator = calculator;
        calculator.compute();
    }

    @Override
    public void undo() {
        //这里的撤销是执行上一次运算
        preCalculator.compute();
    }

    @Override
    public String toString() {
        return calculator.toString();
    }
}
```
然后是Invoker,这里为User类:
```java
package com.command;

import java.util.Stack;

//使用计算器的用户,对于Invoker
public class User {
    private Stack<Command> undos;
    private Stack<Command> redos;

    public User() {
        this.undos = new Stack<>();
        this.redos = new Stack<>();
    }

    public void undo() {
        if (undos.size() == 0) {
            System.out.println("没有撤销步骤");
            return;
        }
        Command cmd = undos.pop();
//        cmd.undo();//撤销不需要再计算了,假如是累计计算撤销才有用
        redos.push(cmd);
        System.out.println("撤销:" + cmd);
    }

    public void redo() {
        if (redos.size() == 0) {
            System.out.println("没有重做步骤");
            return;
        }
        Command cmd = redos.pop();
        cmd.execute();
        undos.push(cmd);
        System.out.println("重做:" + cmd);
    }

    //这才是用户调用的接口
    public void compute(Calculator.Operation operation, int a, int b) {
        ComputeCommand computeCommand = new ComputeCommand(new Calculator(a, b, operation));
        computeCommand.execute();
        undos.add(computeCommand);
    }
}
```
最后是Client,相当于整个应用界面:
```java
package com.command;

public class Client {
    public static void main(String[] args) {
        User user = new User();
        user.compute(Calculator.Operation.ADD, 100, 20);
        user.compute(Calculator.Operation.SUB, -100, 50);
        user.compute(Calculator.Operation.MUL, 10, 30);
        user.undo();
        user.undo();
        user.redo();
    }
}
```

运行结果:
```
计算:100+20=120
计算:-100-50=-150
计算:10*30=300
撤销:10*30=300
撤销:-100-50=-150
计算:-100-50=-150
重做:-100-50=-150
```
