---
title: linux下有趣的工具
tags:
  - linux
  - tool
p: linux/012-linux-fun-tools
date: 2018-02-01 13:51:55
---
纯粹为了娱乐.不过真的很有趣

# 1.装逼网站
[https://hackertyper.net/](https://hackertyper.net/),
[http://geektyper.com/](http://geektyper.com/)

# 2.复古终端
[github](https://github.com/Swordfish90/cool-retro-term)

# 3.假装很忙的命令行
1. [genact](https://github.com/svenstaro/genact)
2. [hollywood](https://github.com/dustinkirkland/hollywood)
3. [blessed](https://github.com/yaronn/blessed-contrib)
第三个还需要会js相关技能才能玩转,还要自己编程实现效果,不过helloworld总是简单的:

1. 安装blessed模块:
```shell
npm install blessed
```
2. 编写代码:
```javascript
var blessed = require('blessed');

// Create a screen object.
var screen = blessed.screen({
  smartCSR: true
});

screen.title = 'my window title';

// Create a box perfectly centered horizontally and vertically.
var box = blessed.box({
  top: 'center',
  left: 'center',
  width: '50%',
  height: '50%',
  content: 'Hello {bold}world{/bold}!',
  tags: true,
  border: {
    type: 'line'
  },
  style: {
    fg: 'white',
    bg: 'magenta',
    border: {
      fg: '#f0f0f0'
    },
    hover: {
      bg: 'green'
    }
  }
});

// Append our box to the screen.
screen.append(box);

// Add a png icon to the box
var icon = blessed.image({
  parent: box,
  top: 0,
  left: 0,
  type: 'overlay',
  width: 'shrink',
  height: 'shrink',
  file: __dirname + '/my-program-icon.png',
  search: false
});

// If our box is clicked, change the content.
box.on('click', function(data) {
  box.setContent('{center}Some different {red-fg}content{/red-fg}.{/center}');
  screen.render();
});

// If box is focused, handle `enter`/`return` and give us some more content.
box.key('enter', function(ch, key) {
  box.setContent('{right}Even different {black-fg}content{/black-fg}.{/right}\n');
  box.setLine(1, 'bar');
  box.insertLine(1, 'foo');
  screen.render();
});

// Quit on Escape, q, or Control-C.
screen.key(['escape', 'q', 'C-c'], function(ch, key) {
  return process.exit(0);
});

// Focus our element.
box.focus();

// Render the screen.
screen.render();
```
3. 运行:
```shell
$ node hello.js
```
4. 效果:
{% asset_img 000.png %}

