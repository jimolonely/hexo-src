---
title: 如何构建个性化linux系统
tags:
  - linux
  - ubuntu
p: linux/000-build-mysystem
date: 2017-12-27 16:24:19
---

# 最新部分
从零开始配置ubuntu

## 基础配置

0. 更换下载源： 软件更新里选择从其他站点下载，选择阿里云
1. 拷贝我的密码脚本到系统（python3 -m http:server）
2. 打开firefox,登录，firefox会同步插件
3. 登录ubuntu账户
4. 打开软件更新，检查更新，更新完毕重启系统（搜索update-manager）
5. 去搜狗输入法官方网站下载ubuntu的包，安装
6. 安装网络监控插件： 
    1. 安装chrome-gnome-shell： `apt install chrome-gnome-shell`
    2. 然后在firefox里安装gnome shell integration插件
    3. 访问：[https://extensions.gnome.org/extension/120/system-monitor/](https://extensions.gnome.org/extension/120/system-monitor/)，安装
7. 重启系统，使插件和输入法生效
8. 安装坚果云：去坚果云官网下载安装包，安装
9. [安装截图软件flame](## screen shot)
10. 配置快捷键：
    1. 命令行界面的： 粘贴改为Ctrl+V
    2. 系统快捷键： 
          1. 主目录： 改为WIN+E
          2. 自定义截图快捷键：运行flameshot gui，Ctrl+Alt+A
11. 登录todoist账号（系统同步），同步清单 
    1. 使用ubuntu自带的TODO软件，选择扩展，打开Todoist，就会自动同步Todoist的列表了

12. 建立常用目录：
    ```shell
    mkdir ~/workspace/Git -pv
    mkdir ~/software/source -pv
    ```
13. {% post_link linux/025-ubuntu-use-navidia-card ubuntu下使用NVIDIA显卡 %}

## 必要软件安装

### git
```
sudo apt-get install git -y
```
然后是配置多用户、多git地址的方法，参考 {% post_link git/000-multi-git-account 一台电脑如何配置多个github账户 %}

我的git账户有：
1. github
2. gitlab
3. 公司内部的gitlab

### Java
首先安装java
```shell
sudo apt-get install default-jdk -y
java -version
```
因为默认是JDK11或最新版本Java，如果需要JDK8，那么再安装：
```shell
sudo apt-get install openjdk-8-jdk -y
java -version
```
然后参考{% post_link linux/018-ubuntu-java ubuntu安装/更新Java %}切换java版本

### maven
```shell
sudo apt-get install maven
mvn -v
```
然后修改为阿里云的镜像，
```
$ mkdir ~/.m2
$ cp /etc/maven/settings.xml ~/.m2/
$ vi ~/.m2/setting.xml
```
修改镜像：
```
<mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>
</mirror>
```
其他类型的linux系统可能不在那，但一定会在用户目录下，可以参考idea的目录：

{% asset_img 000.png %}

### vim

{% post_link linux/006-vim 获取vimrc文件 %}

安装管理插件：
```shell
# 安装vbundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
不过还没完，需要进入vim安装插件，在正常模式输入：
```shell
:BundleInstall
```
安装自动补全插件：

等安装完成后进入~/.vim/bundle/YouCompleteMe安装
```shell
cd ~/.vim/bundle/YouCompleteMe
./install.py --all
```

### vscode

使用ubuntu自带商店安装就是非常慢,  可以使用 [官方推荐](https://code.visualstudio.com/docs/setup/linux) 安装。
```shell
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders
```
然后是vscode的自定义，主要是快捷键： {% post_link tools/016-vscode-config vscode自定义配置 %}

### intellij
虽然商店有，但是下载太慢，还是去官网下吧。

配置导入，记得将之前idea的配置备份打包。

下载安装后，使用自定义application launcher制作启动图标。

### VPN软件
这个就不说了，自己想办法，为了装Google浏览器及其同步。

### chrome浏览器
因为chrome有同步，所以不用备份

开启vpn后，去官网下载chrome，然后登录，同步。

### ubuntu 下有道云
参考github: https://github.com/jamasBian/youdao-note-electron

因为18.10网页版访问不了。

### nodejs & npm

nodejs和npm直接装就行：
```shell
$ sudo apt install nodejs
$ sudo apt install npm
```
但是npm需要配置为非root用户也可以安装包：

参考： {% post_link js/001-npms npm非root安装包问题 %}

再配一下镜像这些。

### Android Studio



## 工作相关

### github项目拉取
1. hexo-src： 编译
2. MyCost

### 公司邮箱
使用Thunderbird登录公司邮箱


# 可选安装

下面是根据需要再安装的软件。

## 其他开发环境相关

### python
(一般都自带了)
#### 更换pypi镜像地址
在~/.pip/pip.conf下配上阿里云的：
```shell
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
```

## 数据库相关

使用idea自带的数据库客户端就很强大。

### 1. dbeaver

### 2. mysql

## 开发工具

### eclipse

### 5.UML绘图工具
一些在线的绘图工具有些不错,但绘图不标准,下面是经过实践的安装版linux下的UML绘制工具:
1. umlet
2. umbrello

### 6.linux下的绘图工具推荐
1. [Dia](https://wiki.gnome.org/Apps/Dia/Download)
2. [Edraws](http://www.edrawsoft.cn/)
3. [像编程一样绘图,可嵌入各个编辑器插件-mermaid](https://github.com/knsv/mermaid)

### 7.linux下录屏工具
1. [SimpleScreenRecorder](http://www.maartenbaert.be/simplescreenrecorder/)

### 8.linux下视频剪辑软件
1. [kdenlive](https://kdenlive.org/)

## 辅助工具

### 1.keepassx ,用于管理密码

### 2.baidupcs
一个百度云命令行工具，地址：https://github.com/GangZhuo/BaiduPCS

### 3.浏览器

#### 3.2firefox


## 备份
只需要备份工作空间即可，将workspace打包然后放到backup目录：
```shell
tar -cf workspace.tar ~/workspace/
mv workspace.tar ~/backup/ -u
```

## network indicator
```shell
sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor  
sudo apt-get update
sudo apt-get install indicator-sysmonitor  
```
[refrence](https://blog.csdn.net/bfboys/article/details/53031998)

在18.x上上面的indicator经常卡死，所以需要换换：

[https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet](https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet)


## screen shot
```
Ctrl+Alt+A: gnome-screenshot -ac
```
不过，我更喜欢flameshot：和qq/微信截图一样方便
```shell
sudo apt install flameshot

flameshot gui
```
然后旧版本不支持文字，可以手动安装最新版：
[github](https://github.com/lupoDharkael/flameshot/issues/11#issuecomment-397700634)

或者直接安装deb包。

## Ubuntu 18.x的右键问题
现在2指单击代表右键，3指单击代表中间键。

如果实在不习惯，可以安装gnome-tweaks.如下，选择区域.

{% asset_img 001.png %}

## Ubuntu播放wmv格式视频
```shell
$ sudo apt-get install smplayer
```
安装完成后，在Ubuntu的系统设置->详细信息->默认应用程序->视频中，讲播放视频的默认软件改为smplayer就可以了.

mp4等各种格式都能播放。

## ubuntu下的FTP软件

在ubunut商店有：filezilla.

## ubuntu下载btorrent
使用软件：ktorrent
```shell
sudo apt-get install ktorrent
```
## ubuntu下载迅雷链接
迅雷下载协议是经过加密的,如：
thunder://QUFlZDJrOi8vfGZpbGV8JUU4JUExJThDJUU1JUIwJUI4JUU4JUI1JUIwJUU4JTgyJTg5LlRoZS5XYWxraW5nLkRlYWQuUzA2RTAxLiVFNCVCOCVBRCVFOCU4QiVCMSVFNSVBRCU5NyVFNSVCOSU5NS5IRFRWcmlwLjEwMjR4NTc2Lm1wNHw2NDg3NTg1MDl8ZjIyZmI2OTRjMDQ0ZmYyNjU0MjhhNTEzNWVhYzhiOTB8aD12eXFsNHFjNHpmYmx0eWNqdW1rcnNibDJza2JscTJsZnwvWlo=
直接在Linux下面是没有办法下载的。

先解码：
```shell
echo url | base64 -d 
```
显示结果是：
AAed2k://|file|%E8%A1%8C%E5%B0%B8%E8%B5%B0%E8%82%89.The.Walking.Dead.S06E01.%E4%B8%AD%E8%8B%B1%E5%AD%97%E5%B9%95.HDTVrip.1024x576.mp4|648758509|f22fb694c044ff265428a5135eac8b90|h=vyql4qc4zfbltycjumkrsbl2skblq2lf|/ZZ

所以解密后的地址是：ed2k://|file|%E8%A1%8C%E5%B0%B8%E8%B5%B0%E8%82%89.The.Walking.Dead.S06E01.%E4%B8%AD%E8%8B%B1%E5%AD%97%E5%B9%95.HDTVrip.1024x576.mp4|648758509|f22fb694c044ff265428a5135eac8b90|h=vyql4qc4zfbltycjumkrsbl2skblq2lf|/

安装amule软件
```shell
sudo apt-get install amule
```

复制解密后的地址，粘贴到amule里即可.

## ubuntu电子书阅读器

calibre

FBReader

推荐fbreader.

## ubuntu todo list
ubuntu18.04自带了一款todo应用，我开始一直以为它很简陋，连同步功能都没有，
然后发现还有一个插件，可以连接到[todoist](https://todoist.com),实现同步。

于是注册了账号，使用了下，还不错。

# ubuntu 单点登录账户
ubuntu也像windows有账户了，可以试试。


