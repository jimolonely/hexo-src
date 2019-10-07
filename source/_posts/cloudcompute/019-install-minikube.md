---
title: 安装minikube
tags:
  - linux
  - k8s
p: cloudcompute/019-install-minikube
date: 2019-10-03 08:41:30
---

[minikube github](https://github.com/kubernetes/minikube/releases)

[官方安装文档](https://kubernetes.io/docs/tasks/tools/install-minikube/)

# 1.安装kubectl

[https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)

```s
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

$ chmod +x ./kubectl

$ sudo mv ./kubectl /usr/local/bin/kubectl

$ kubectl version
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.1", GitCommit:"d647ddbd755faf07169599a625faf302ffc34458", GitTreeState:"clean", BuildDate:"2019-10-02T17:01:15Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

如果像我一样使用的是ubuntu，那就用snap装把：
```s
sudo snap install kubectl --classic
```

# 2.安装Hypervisor

可以是以下2种：

* [KVM](https://www.linux-kvm.org/page/Main_Page)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

但是：凡事也有例外

> 注意：Minikube还支持`--vm-driver = none`选项，该选项在主机而非VM上运行Kubernetes组件。 使用此驱动程序需要Docker和Linux环境，但不需要管理程序。 当使用none驱动程序时，建议使用Docke的apt安装。（docker，当使用none驱动程序时。docker的snap安装不适用于minikube。

**装virtualbox**

1. 下载最新安装包：[https://www.virtualbox.org/wiki/Linux_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads)

2. 安装:
    ```s
    $ sudo dpkg -i virtualbox-6.0_6.0.12-133076_Ubuntu_bionic_amd64.deb

    # 遇到未满足的依赖，安装解决
    $ sudo apt install -f
    ```

因为我装了docker的，所以先不安装,顺便演示下错误。

# 3.安装minikube

```s
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

$ sudo mkdir -p /usr/local/bin/
$ sudo install minikube /usr/local/bin/
```

# 4.验证

```s
$ minikube status
host: 
kubelet: 
apiserver: 
kubectl: 

$ minikube start
😄  minikube v1.4.0 on Ubuntu 18.04
💿  Downloading VM boot image ...
    > minikube-v1.4.0.iso.sha256: 65 B / 65 B [--------------] 100.00% ? p/s 0s
    > minikube-v1.4.0.iso: 135.73 MiB / 135.73 MiB [-] 100.00% 3.95 MiB p/s 34s
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🔄  Retriable failure: create: precreate: VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🔄  Retriable failure: create: precreate: VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🔄  Retriable failure: create: precreate: VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🔄  Retriable failure: create: precreate: VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path

💣  Unable to start VM
❌  Error: [VBOX_NOT_FOUND] create: precreate: VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path
💡  Suggestion: Install VirtualBox, or select an alternative value for --vm-driver
📘  Documentation: https://minikube.sigs.k8s.io/docs/start/
⁉️   Related issues:
    ▪ https://github.com/kubernetes/minikube/issues/3784
```

看来默认他是使用virtualbox，然而我没有装，那么试试不要driver把：

```s
$ sudo minikube start --vm-driver=none
😄  minikube v1.4.0 on Ubuntu 18.04
🤹  Running on localhost (CPUs=12, Memory=7809MB, Disk=239863MB) ...
ℹ️   OS release is Ubuntu 18.04.3 LTS
🐳  Preparing Kubernetes v1.16.0 on Docker 19.03.2 ...
E1003 09:02:48.020607    9573 cache_images.go:79] CacheImage kubernetesui/dashboard:v2.0.0-beta4 -> /home/jack/.minikube/cache/images/kubernetesui/dashboard_v2.0.0-beta4 failed: Get https://index.docker.io/v2/kubernetesui/dashboard/manifests/v2.0.0-beta4: x509: certificate is valid for staging.ogwee.com, staging.gonift.com, perf.gonift.com, staging.getmynift.com, st.nift.me, not index.docker.io

```

看起来也报了一大堆错，，原因是我装的docker与它要求的不一样。

那我们还是乖乖的装hypervisor把，见上面的操作，然后再次启动： 如果依然这样启动`sudo minikube start`,还是会报错，因为保留的是上一次状态，所以先删除：

```s
$ sudo minikube delete
🔄  Uninstalling Kubernetes v1.16.0 using kubeadm ...
🔥  Deleting "minikube" in none ...
💔  The "minikube" cluster has been deleted.

# 不让root启动
jack@jack:~/software$ sudo minikube start
😄  minikube v1.4.0 on Ubuntu 18.04
🛑  The "virtualbox" driver should not be used with root privileges.
💡  If you are running minikube within a VM, consider using --vm-driver=none:
📘    https://minikube.sigs.k8s.io/docs/reference/drivers/none/

$ minikube start
😄  minikube v1.4.0 on Ubuntu 18.04
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.16.0 on Docker 18.09.9 ...
。。。
💣  Failed to setup kubeconfig: Error reading file "/home/jack/.kube/config": open /home/jack/.kube/config: permission denied
```
看起来是权限问题，那就解决它：
```s
$ sudo chmod 777 -R /home/jack/.kube/config

$ sudo chmod 777 -R /home/jack/.minikube
```

最后还是出现了网络问题。

```s
E1007 09:36:37.141950    7393 cache_images.go:79] CacheImage k8s.gcr.io/kube-addon-manager:v9.0.2 -> /home/jack/.minikube/cache/images/k8s.gcr.io/kube-addon-manager_v9.0.2 failed: fetching image: Get https://k8s.gcr.io/v2/: dial tcp 108.177.125.82:443: i/o timeout
E1007 09:36:37.142572    7393 cache_images.go:79] CacheImage k8s.gcr.io/pause:3.1 -> /home/jack/.minikube/cache/images/k8s.gcr.io/pause_3.1 failed: fetching image: Get https://k8s.gcr.io/v2/: dial tcp 108.177.125.82:443: i/o timeout
```

# 5.解决网络问题

从官方issue得知，不能访问google镜像很正常，可以使用代理镜像：[https://github.com/kubernetes/minikube/issues/3860](https://github.com/kubernetes/minikube/issues/3860)

具体方法如下：

```s
minikube start --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```
最终的运行结果如下：
```s
$ minikube start --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
😄  minikube v1.4.0 on Ubuntu 18.04
✅  Using image repository registry.cn-hangzhou.aliyuncs.com/google_containers
💡  Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
🏃  Using the running virtualbox "minikube" VM ...
⌛  Waiting for the host to be provisioned ...
🐳  Preparing Kubernetes v1.16.0 on Docker 18.09.9 ...
🔄  Relaunching Kubernetes using kubeadm ... 
⌛  Waiting for: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "minikube"
```

然后我们可以使用`kubectl`命令做实验了：

```s
$ kubectl get pods
No resources found in default namespace.

$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443
KubeDNS is running at https://192.168.99.100:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

## 国内镜像

[http://mirror.azk8s.cn/help/gcr-proxy-cache.html](http://mirror.azk8s.cn/help/gcr-proxy-cache.html)

# 6.总结

最后的测试使用见后续博客。


**下次启动时，直接使用缓存：** `minikube start --cache`






