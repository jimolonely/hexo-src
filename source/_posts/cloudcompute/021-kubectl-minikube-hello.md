---
title: minikube-kubectl实践使用入门
tags:
  - k8s
p: cloudcompute/021-kubectl-minikube-hello
date: 2019-10-07 10:42:11
---

# 查看集群信息

```s
$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443
KubeDNS is running at https://192.168.99.100:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


$ kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
minikube   Ready    <none>   48m   v1.16.0
```

# 创建应用

```s
$ kubectl run nginx --image=gcr.azk8s.cn/google_containers/nginx
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/nginx created

$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
nginx                 0/1     1            0           4s
```

然而并没有应用起来,查看一下状态：

```s
$ kubectl describe pods nginx
Name:           nginx-694785858b-dkxrj
Namespace:      default
Priority:       0
Node:           minikube/10.0.2.15
Start Time:     Mon, 07 Oct 2019 11:13:33 +0800
Labels:         pod-template-hash=694785858b
                run=nginx
Annotations:    <none>
Status:         Pending
IP:             
IPs:            <none>
Controlled By:  ReplicaSet/nginx-694785858b
Containers:
  nginx:
    Container ID:   
    Image:          gcr.azk8s.cn/google_containers/nginx
    Image ID:       
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-7dsd7 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-7dsd7:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-7dsd7
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age        From               Message
  ----    ------     ----       ----               -------
  Normal  Scheduled  <unknown>  default-scheduler  Successfully assigned default/nginx-694785858b-dkxrj to minikube
  Normal  Pulling    26s        kubelet, minikube  Pulling image "gcr.azk8s.cn/google_containers/nginx"
```

看到正在拉取镜像,经过了4分钟左右，终于起来了：

```s
Events:
  Type    Reason     Age        From               Message
  ----    ------     ----       ----               -------
  Normal  Scheduled  <unknown>  default-scheduler  Successfully assigned default/nginx-694785858b-dkxrj to minikube
  Normal  Pulling    3m11s      kubelet, minikube  Pulling image "gcr.azk8s.cn/google_containers/nginx"
  Normal  Pulled     19s        kubelet, minikube  Successfully pulled image "gcr.azk8s.cn/google_containers/nginx"
  Normal  Created    19s        kubelet, minikube  Created container nginx
  Normal  Started    19s        kubelet, minikube  Started container nginx

$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
nginx                 1/1     1            1           3m9s
```

# 查看应用

开启代理

```s
$ echo -e "\n\n\n\e[92mStarting Proxy. After starting it will not output a response. Please click the first Terminal Tab\n"; 
$ kubectl proxy

$ curl http://localhost:8001/version
{
  "major": "1",
  "minor": "16",
  "gitVersion": "v1.16.0",
  "gitCommit": "2bd9643cee5b3b3a5ecbd3af49d09018f0773c77",
  "gitTreeState": "clean",
  "buildDate": "2019-09-18T14:27:17Z",
  "goVersion": "go1.12.9",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

获取pod名字：
```s
$ export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
$ echo Name of the Pod: $POD_NAME
nginx-6db489d4b7-lbzgr
```

通过代理访问nginx应用：可以看到首页

```s
$ curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/proxy/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

# 探索应用

```s
$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6db489d4b7-lbzgr   1/1     Running   0          5m38s


$ kubectl describe pods
Name:         nginx-6db489d4b7-lbzgr
Namespace:    default
Priority:     0
Node:         minikube/10.0.2.15
Start Time:   Mon, 07 Oct 2019 11:25:14 +0800
Labels:       pod-template-hash=6db489d4b7
              run=nginx
Annotations:  <none>
Status:       Running
IP:           172.17.0.4
IPs:
  IP:           172.17.0.4
Controlled By:  ReplicaSet/nginx-6db489d4b7
Containers:
  nginx:
    Container ID:   docker://9ae6de1486054fef58a5e59a19addeaf98cb0f523a60cb7bd146dcdc5def628a
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:aeded0f2a861747f43a01cf1018cf9efe2bdd02afd57d2b11fcc7fcadc16ccd1
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 07 Oct 2019 11:25:23 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-7dsd7 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-7dsd7:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-7dsd7
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age        From               Message
  ----    ------     ----       ----               -------
  Normal  Scheduled  <unknown>  default-scheduler  Successfully assigned default/nginx-6db489d4b7-lbzgr to minikube
  Normal  Pulling    5m51s      kubelet, minikube  Pulling image "nginx"
  Normal  Pulled     5m43s      kubelet, minikube  Successfully pulled image "nginx"
  Normal  Created    5m43s      kubelet, minikube  Created container nginx
  Normal  Started    5m43s      kubelet, minikube  Started container nginx
```
查看日志：

```s
$ kubectl logs $POD_NAME
172.17.0.1 - - [07/Oct/2019:03:25:48 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.58.0" "127.0.0.1, 192.168.99.1"
```

在应用里执行命令

```s
# 查看环境变量
$ kubectl exec $POD_NAME env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=nginx-6db489d4b7-lbzgr
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
NGINX_VERSION=1.17.4
NJS_VERSION=0.3.5
PKG_RELEASE=1~buster
HOME=/root

# 进入容器
$ kubectl exec -it $POD_NAME bash
root@nginx-6db489d4b7-lbzgr:/# ls
bin  boot  dev	etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
```

# 公开访问应用

需要用到service，关于k8s中的服务是个什么概念，看[官方介绍](https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/)：

> Kubernetes中的服务是一种抽象，定义了Pod的逻辑集合和访问Pod的策略

查看服务：

```s
$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   44m
```

暴露80端口：

```s
$ kubectl expose deployment/nginx --type="NodePort" --port 80
service/nginx exposed

$ kubectl get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        65m
nginx        NodePort    10.103.123.100   <none>        80:30119/TCP   101s
```
关于这里的type有4种，具体参考上述文档。

查到其内部端口：

```s
$ export NODE_PORT=$(kubectl get services/nginx -o go-template='{{(index .spec.ports 0).nodePort}}')

$ echo $NODE_PORT
30119
```

通过暴露的端口访问应用：

```s
$ curl $(minikube ip):$NODE_PORT
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## 打标签

通过标签查询
```s
$ kubectl get pods -l run=nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6db489d4b7-lbzgr   1/1     Running   0          71m

$ kubectl get services -l run=nginx
NAME    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.103.123.100   <none>        80:30119/TCP   38m
```

设置变量：

```s
$ export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')

$ echo Name of the Pod: $POD_NAME
Name of the Pod: nginx-6db489d4b7-lbzgr
```

打标签
```s
# 打
$ kubectl label pod $POD_NAME app=v1
pod/nginx-6db489d4b7-lbzgr labeled

# 查看描述
$ kubectl describe pods $POD_NAME
Name:         nginx-6db489d4b7-lbzgr
Namespace:    default
Labels:       app=v1
              pod-template-hash=6db489d4b7
              run=nginx

# 根据新标签获取
$ kubectl get pods -l app=v1
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6db489d4b7-lbzgr   1/1     Running   0          76m
```

通过标签删除服务：
```s
$ kubectl delete service -l run=nginx
service "nginx" deleted

$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   109m
```

# 扩容

## 扩容
目前就一个应用
```s
~$ kubectl get deployments
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           82m
```

扩到3个：
```s
$ kubectl scale deployments/nginx --replicas=3
deployment.apps/nginx scaled

$ kubectl get deployments
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   3/3     3            3           83m
```

查看pod：
```s
$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
nginx-6db489d4b7-7ntbs   1/1     Running   0          86s   172.17.0.6   minikube   <none>           <none>
nginx-6db489d4b7-kqnj4   1/1     Running   0          86s   172.17.0.5   minikube   <none>           <none>
nginx-6db489d4b7-lbzgr   1/1     Running   0          84m   172.17.0.4   minikube   <none>           <none>


$ kubectl describe deployments/nginx
Name:                   nginx
Namespace:              default
CreationTimestamp:      Mon, 07 Oct 2019 11:25:14 +0800
Labels:                 run=nginx
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               run=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  run=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-6db489d4b7 (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  2m16s  deployment-controller  Scaled up replica set nginx-6db489d4b7 to 3
```

## 负载均衡

先暴露端口创建服务
```s
$ kubectl expose deployments/nginx --type="NodePort" --port 80
service/nginx exposed

$ kubectl get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        155m
nginx        NodePort    10.103.106.245   <none>        80:32396/TCP   6s
```

获得其端口：
```s
$ kubectl describe services/nginx
Name:                     nginx
Namespace:                default
Labels:                   run=nginx
Annotations:              <none>
Selector:                 run=nginx
Type:                     NodePort
IP:                       10.103.106.245
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32396/TCP
Endpoints:                172.17.0.4:80,172.17.0.5:80,172.17.0.6:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```
看到上面endpoints的ip有3个，这时候访问：`$ curl $(minikube ip):32396`会默认采用轮训策略。

## 缩容

把副本写小一点就好了：

```s
$ kubectl scale deployments/nginx --replicas=2
deployment.apps/nginx scaled

$ kubectl get deployments
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     2            2           130m

$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE    IP           NODE       NOMINATED NODE   READINESS GATES
nginx-6db489d4b7-kqnj4   1/1     Running   0          46m    172.17.0.5   minikube   <none>           <none>
nginx-6db489d4b7-lbzgr   1/1     Running   0          130m   172.17.0.4   minikube   <none>           <none>

$ kubectl describe deployments/nginx
Name:                   nginx
Namespace:              default
CreationTimestamp:      Mon, 07 Oct 2019 11:25:14 +0800
Labels:                 run=nginx
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               run=nginx
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  47m   deployment-controller  Scaled up replica set nginx-6db489d4b7 to 3
  Normal  ScalingReplicaSet  38s   deployment-controller  Scaled down replica set nginx-6db489d4b7 to 2
```

# 升级

设置新的镜像
```s
$ kubectl set image deployments/nginx nginx=gcr.azk8s.cn/google_containers/nginx:v1.16.1

$ kubectl get deployments
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     1            2           162m
```

查看更新状态
```s
$ kubectl rollout status deployments/nginx
Waiting for deployment "nginx" rollout to finish: 1 out of 2 new replicas have been updated...
```
回滚
```s
$ kubectl rollout undo deployments/nginx
deployment.apps/nginx rolled back
```








