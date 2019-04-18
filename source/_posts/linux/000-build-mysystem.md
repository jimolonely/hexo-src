---
title: 如何构建个性化linux系统
tags:
  - linux
  - ubuntu
p: linux/000-build-mysystem
date: 2017-12-27 16:24:19
---
# 开始
当然是如何打造个性化系统,一般可以按以下步骤来.
## 常用文件夹
```shell
sudo mkdir ~/software/source -pv
sudo mkdir ~/software/bin -pv
mkdir ~/knowme/books -pv
mkdir ~/workspace/Git -pv
mkdir ~/backup
sudo apt-get update
```

## Install git
```shell
sudo apt-get install git -y

git config --global user.name "jimolonely"
git config --global user.email xxx@163.com
```
### 配置保存密码
#### 方法1
```shell
git config --global credential.helper store
```
#### 方法2
在~目录下创建.gitconfig文件，写入：
```shell
[credential]    
    helper = store
```

## 开发语言环境相关

### Install java
```shell
sudo apt-get install default-jdk -y
java -version
```

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

### maven
```shell
sudo apt-get install maven
mvn -v
```
然后修改为阿里云的镜像，在/etc/maven/settings.xml
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

## 数据库相关

### 1. dbeaver

### 2. mysql


## 开发工具

### 1.eclipse

### 2.intellij

### 3.vim

#### 3.1 clone vimrc
```shell
cd ~/workspace/Git/
git clone https://github.com/jimolonely/myshell.git
cp myshell/vim/.vimrc ~/.vimrc
cp -r myshell/vim/.vim/ ~
# 安装vbundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
不过还没完，需要进入vim安装插件，在正常模式输入：
```shell
:BundleInstall
```
等安装完成后进入~/.vim/bundle/YouCompleteMe安装
```shell
cd ~/.vim/bundle/YouCompleteMe
./install.py --all
```

### 4.vscode

使用ubuntu自带商店安装会出现自带输入法不能输入中文问题,  使用 [官方推荐](https://code.visualstudio.com/docs/setup/linux) 安装。
```shell
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders
```
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
#### 3.1chrome
因为chrome有同步，所以不用备份

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


