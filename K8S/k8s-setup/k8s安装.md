# 二、安装k8s


k8s所有版本的github库：
https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.22.md#downloads-for-v1222


## 1、添加阿里云YUM软件源
[root@master-1 ~]#  cd /etc/yum.repos.d/
[root@master-1 yum.repos.d]# vim kubernetes.repo               
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg


## 2、版本查看
[root@master-1 yum.repos.d]# yum list kubelet --showduplicates |sort -r

本文安装的kubelet版本是1.16.4，该版本支持的docker最高版本是1.22.2


## 3、安装kubelet、 kubeadm、 kubectl
[root@master-1 rpm-gpg]# yum install  kubelet-1.19.9-0 kubeadm-1.19.9-0 kubectl-1.19.9-0 --nogpgcheck -y
Installed:
  kubeadm.x86_64 0:1.19.9-0                           kubectl.x86_64 0:1.19.9-0                           kubelet.x86_64 0:1.19.9-0                          
Dependency Installed:
  conntrack-tools.x86_64 0:1.4.4-7.el7                 cri-tools.x86_64 0:1.13.0-0                          kubernetes-cni.x86_64 0:0.8.7-0                   
  libnetfilter_cthelper.x86_64 0:1.0.0-11.el7          libnetfilter_cttimeout.x86_64 0:1.0.0-7.el7          libnetfilter_queue.x86_64 0:1.0.2-2.el7_2         
  socat.x86_64 0:1.7.3.2-2.el7                        

Complete!


######安装包说明
kubelet 运行在集群所有节点上，用于启动Pod和容器等对象的工具
kubeadm 用于初始化集群，启动集群的命令工具
kubectl 用于和集群通信的命令行，通过kubectl可以部署和管理应用，查看各种资源，创建、删除和更新各种组件


######报错： 
Failing package is: kubectl-1.16.2-0.x86_64
GPG Keys are configured as: https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg

解：用--nogpgcheck跳过key校验


######此时，还不能启动kubelet，因为此时配置还不能，现在仅仅可以设置开机自启动
[root@master-1 ~]# systemctl enable kubelet 
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/lib/systemd/system/kubelet.service.
[root@node-1 yum.repos.d]# systemctl enable kubelet 
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/lib/systemd/system/kubelet.service.
[root@node-2 yum.repos.d]# systemctl enable kubelet 
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/lib/systemd/system/kubelet.service.


#备注：以上操作所有的节点都要操作。
#如果以下步操作失败，可以通过 kubeadm reset 命令来清理环境重新安装。


## 4、部署Kubernetes Master
#### 1)master：初始化kubeadm
[root@master-1 ~]# kubeadm init \
> --apiserver-advertise-address=172.16.201.134 \
> --image-repository registry.aliyuncs.com/google_containers \
> --kubernetes-version v1.19.9 \
> --service-cidr=10.1.0.0/16 \
> --pod-network-cidr=10.244.0.0/16

######参数说明：
–image-repository string：    这个用于指定从什么位置来拉取镜像（1.13版本才有的），默认值是k8s.gcr.io，我们将其指定为国内镜像地址：registry.aliyuncs.com/google_containers
–kubernetes-version string： 指定kubenets版本号，默认值是stable-1，会导致从https://dl.k8s.io/release/stable-1.txt下载最新的版本号，我们可以将其指定为固定版本（v1.15.1）来跳过网络请求。
–apiserver-advertise-address  指明用 Master 的哪个 interface 与 Cluster 的其他节点通信。如果 Master 有多个 interface，建议明确指定，如果不指定，kubeadm 会自动选择有默认网关的 interface。
–pod-network-cidr      指定 Pod 网络的范围。Kubernetes 支持多种网络方案，而且不同网络方案对 –pod-network-cidr有自己的要求，这里设置为10.244.0.0/16 是因为我们将使用 flannel 网络方案，必须设置成这个 CIDR。




W0922 12:01:32.245984    2203 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.19.9
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local master-1] and IPs [10.1.0.1 172.16.201.134]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [localhost master-1] and IPs [172.16.201.134 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [localhost master-1] and IPs [172.16.201.134 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 66.506601 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.19" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master-1 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master-1 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: cdeix4.h84buwepsp1yx14v
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.201.134:6443 --token cdeix4.h84buwepsp1yx14v \
    --discovery-token-ca-cert-hash sha256:39475f24cb52cafd15989e7451da8b79dbae87a57f5b10354ee14cf409c449ad 
[root@master-1 ~]# 

##### 注意：
建议至少2 cpu ,2G，非硬性要求，1cpu，1G也可以搭建起集群。
1个cpu的话初始化master的时候会报 [WARNING NumCPU]: the number of available CPUs 1 is less than the required 2
部署插件或者pod时可能会报warning：FailedScheduling：Insufficient cpu, Insufficient memory
如果出现这种提示，说明你的虚拟机分配的CPU为1核，需要重新设置虚拟机master节点内核数。


##### 问题：
[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/

##### 解决
更改docker的启动参数
$ vim /usr/lib/systemd/system/docker.service
#####ExecStart=/usr/bin/dockerd
ExecStart=/usr/bin/dockerd --exec-opt native.cgroupdriver=systemd
重启docker
[root@master-1 ~]# systemctl daemon-reload
[root@master-1 ~]# systemctl restart docker



#### 2)node节点执行加入集群：
[root@node-1 yum.repos.d]# kubeadm join 172.16.201.134:6443 --token cdeix4.h84buwepsp1yx14v \
> --discovery-token-ca-cert-hash sha256:39475f24cb52cafd15989e7451da8b79dbae87a57f5b10354ee14cf409c449ad

[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

#### 3)node查看状态：
[root@node-1 yum.repos.d]# docker ps -a
CONTAINER ID        IMAGE                                                COMMAND                  CREATED             STATUS                         PORTS               NAMES
4e8fd3436209        registry.aliyuncs.com/google_containers/kube-proxy   "/usr/local/bin/kube…"   2 minutes ago       Up 2 minutes                                       k8s_kube-proxy_kube-proxy-bkck2_kube-system_13d1d3e9-de92-4601-9486-cb9fae99f600_0
251063bf8160        registry.aliyuncs.com/google_containers/pause:3.2    "/pause"                 2 minutes ago       Up 2 minutes                                       k8s_POD_kube-proxy-bkck2_kube-system_13d1d3e9-de92-4601-9486-cb9fae99f600_0
[root@node-1 yum.repos.d]# 

[root@node-2 yum.repos.d]# docker ps -a
CONTAINER ID        IMAGE                                                COMMAND                  CREATED             STATUS                         PORTS               NAMES
529215b26f16        registry.aliyuncs.com/google_containers/kube-proxy   "/usr/local/bin/kube…"   2 minutes ago       Up 2 minutes                                       k8s_kube-proxy_kube-proxy-phjdh_kube-system_3f1d0d74-2dcd-4d48-82f8-37b2a5558a0c_0
2f5f9eaf2f56        registry.aliyuncs.com/google_containers/pause:3.2    "/pause"                 2 minutes ago       Up 2 minutes                                       k8s_POD_kube-proxy-phjdh_kube-system_3f1d0d74-2dcd-4d48-82f8-37b2a5558a0c_0



[root@node-1 yum.repos.d]#  docker images
REPOSITORY                                           TAG                 IMAGE ID            CREATED             SIZE
registry.aliyuncs.com/google_containers/kube-proxy   v1.19.9             4a76fb49d490        6 months ago        118MB
hello-world                                          latest              d1165f221234        6 months ago        13.3kB
registry.aliyuncs.com/google_containers/pause        3.2                 80d28bedfe5d        19 months ago       683kB
[root@node-1 yum.repos.d]# 


[root@node-2 yum.repos.d]# docker images
REPOSITORY                                           TAG                 IMAGE ID            CREATED             SIZE
registry.aliyuncs.com/google_containers/kube-proxy   v1.19.9             4a76fb49d490        6 months ago        118MB
hello-world                                          latest              d1165f221234        6 months ago        13.3kB
registry.aliyuncs.com/google_containers/pause        3.2                 80d28bedfe5d        19 months ago       683kB

#### 4) master查看状态：
[root@master-1 kubernetes]# docker images
REPOSITORY                                                        TAG                 IMAGE ID            CREATED             SIZE
registry.aliyuncs.com/google_containers/kube-proxy                v1.19.9             4a76fb49d490        6 months ago        118MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.19.9             1a4f1f05177f        6 months ago        119MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.19.9             a8fd6520f73d        6 months ago        111MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.19.9             8f1e66e40394        6 months ago        46.5MB
hello-world                                                       latest              d1165f221234        6 months ago        13.3kB
registry.aliyuncs.com/google_containers/etcd                      3.4.13-0            0369cf4303ff        13 months ago       253MB
registry.aliyuncs.com/google_containers/coredns                   1.7.0               bfe3a36ebd25        15 months ago       45.2MB
registry.aliyuncs.com/google_containers/pause                     3.2                 80d28bedfe5d        19 months ago       683kB
[root@master-1 kubernetes]# 



#### 5) master:使用kubectl工具
[root@master-1 kubernetes]# mkdir -p $HOME/.kube
[root@master-1 kubernetes]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master-1 kubernetes]# sudo chown $(id -u):$(id -g) $HOME/.kube/config



#### 6) master:安装Pod网络插件（CNI）(master)
master:目前是NotReady
[root@master-1 kubernetes]#  kubectl get nodes
NAME       STATUS     ROLES    AGE   VERSION
master-1   NotReady   master   30m   v1.19.9
node-1     NotReady   <none>   13m   v1.19.9
node-2     NotReady   <none>   13m   v1.19.9


[root@master-1 ~]#wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

[root@master-1 ~]# cat kube-flannel.yml
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp.flannel.unprivileged
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
    apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
spec:
  privileged: false
  volumes:
  - configMap
  - secret
  - emptyDir
  - hostPath
  allowedHostPaths:
  - pathPrefix: "/etc/cni/net.d"
  - pathPrefix: "/etc/kube-flannel"
  - pathPrefix: "/run/flannel"
  readOnlyRootFilesystem: false
  # Users and groups
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  # Privilege Escalation
  allowPrivilegeEscalation: false
  defaultAllowPrivilegeEscalation: false
  # Capabilities
  allowedCapabilities: ['NET_ADMIN', 'NET_RAW']
  defaultAddCapabilities: []
  requiredDropCapabilities: []
  # Host namespaces
  hostPID: false
  hostIPC: false
  hostNetwork: true
  hostPorts:
  - min: 0
    max: 65535
  # SELinux
  seLinux:
    # SELinux is unused in CaaSP
    rule: 'RunAsAny'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: flannel
rules:
- apiGroups: ['extensions']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames: ['psp.flannel.unprivileged']
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes/status
  verbs:
  - patch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: flannel
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: flannel
subjects:
- kind: ServiceAccount
  name: flannel
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flannel
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
  labels:
    tier: node
    app: flannel
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "flannel",
          "delegate": {
            "hairpinMode": true,
            "isDefaultGateway": true
          }
        },
        {
          "type": "portmap",
          "capabilities": {
            "portMappings": true
          }
        }
      ]
    }
  net-conf.json: |
    {
      "Network": "10.244.0.0/16",
      "Backend": {
        "Type": "vxlan"
      }
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-flannel-ds
  namespace: kube-system
  labels:
    tier: node
    app: flannel
spec:
  selector:
    matchLabels:
      app: flannel
  template:
    metadata:
      labels:
        tier: node
        app: flannel
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
      hostNetwork: true
      priorityClassName: system-node-critical
      tolerations:
      - operator: Exists
        effect: NoSchedule
      serviceAccountName: flannel
      initContainers:
      - name: install-cni
        image: quay.io/coreos/flannel:v0.14.0
        command:
        - cp
        args:
        - -f
        - /etc/kube-flannel/cni-conf.json
        - /etc/cni/net.d/10-flannel.conflist
        volumeMounts:
        - name: cni
          mountPath: /etc/cni/net.d
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      containers:
      - name: kube-flannel
        image: quay.io/coreos/flannel:v0.14.0
        command:
        - /opt/bin/flanneld
        args:
        - --ip-masq
        - --kube-subnet-mgr
        resources:
          requests:
            cpu: "100m"
            memory: "50Mi"
          limits:
            cpu: "100m"
            memory: "50Mi"
        securityContext:
          privileged: false
          capabilities:
            add: ["NET_ADMIN", "NET_RAW"]
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: run
          mountPath: /run/flannel
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      volumes:
      - name: run
        hostPath:
          path: /run/flannel
      - name: cni
        hostPath:
          path: /etc/cni/net.d
      - name: flannel-cfg
        configMap:
          name: kube-flannel-cfg
[root@master-1 ~]# 

#### 7)master:安装 ，执行命令：
[root@master-1 ~]#kubectl apply -f kube-flannel.yml
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created       


#### 8)master:查看安装状态： 
[root@master-1 ~]# kubectl get pods -n kube-system
NAME                               READY   STATUS            RESTARTS   AGE
coredns-6d56c8448f-mp5lz           0/1     Pending           0          38m
coredns-6d56c8448f-wnqxj           0/1     Pending           0          38m
etcd-master-1                      1/1     Running           0          38m
kube-apiserver-master-1            1/1     Running           0          38m
kube-controller-manager-master-1   1/1     Running           0          38m
kube-flannel-ds-mmhsm              1/1     Running           0          37s
kube-flannel-ds-rz2xj              0/1     PodInitializing   0          37s
kube-flannel-ds-ts9fm              1/1     Running           0          37s
kube-proxy-bkck2                   1/1     Running           0          22m
kube-proxy-c6fdx                   1/1     Running           0          38m
kube-proxy-phjdh                   1/1     Running           0          21m
kube-scheduler-master-1            1/1     Running           0          38m

##### master:安装好了，kube-flannel都Running了
[root@master-1 ~]# kubectl get pods -n kube-system
NAME                               READY   STATUS    RESTARTS   AGE
coredns-6d56c8448f-mp5lz           1/1     Running   0          75m
coredns-6d56c8448f-wnqxj           1/1     Running   0          75m
etcd-master-1                      1/1     Running   0          38m
kube-apiserver-master-1            1/1     Running   0          38m
kube-controller-manager-master-1   1/1     Running   0          38m
kube-flannel-ds-mmhsm              1/1     Running   0          38s
kube-flannel-ds-rz2xj              1/1     Running   0          38s
kube-flannel-ds-ts9fm              1/1     Running   0          38s
kube-proxy-bkck2                   1/1     Running   0          22m
kube-proxy-c6fdx                   1/1     Running   0          38m
kube-proxy-phjdh                   1/1     Running   0          21m
kube-scheduler-master-1            1/1     Running   0          38m



##### master:再次查看node，可以看到状态为ready
[root@master-1 ~]# kubectl get node
NAME       STATUS   ROLES    AGE   VERSION
master-1   Ready    master   39m   v1.19.9
node-1     Ready    <none>   22m   v1.19.9
node-2     Ready    <none>   22m   v1.19.9

##### master:
[root@master-1 ~]# docker images
REPOSITORY                                                        TAG                 IMAGE ID            CREATED             SIZE
quay.io/coreos/flannel                                            v0.14.0             8522d622299c        4 months ago        67.9MB
registry.aliyuncs.com/google_containers/kube-proxy                v1.19.9             4a76fb49d490        6 months ago        118MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.19.9             1a4f1f05177f        6 months ago        119MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.19.9             8f1e66e40394        6 months ago        46.5MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.19.9             a8fd6520f73d        6 months ago        111MB
hello-world                                                       latest              d1165f221234        6 months ago        13.3kB
registry.aliyuncs.com/google_containers/etcd                      3.4.13-0            0369cf4303ff        13 months ago       253MB
registry.aliyuncs.com/google_containers/coredns                   1.7.0               bfe3a36ebd25        15 months ago       45.2MB
registry.aliyuncs.com/google_containers/pause                     3.2                 80d28bedfe5d        19 months ago       683kB

######master:
[root@master-1 ~]# docker ps -a
CONTAINER ID        IMAGE                                               COMMAND                  CREATED             STATUS                     PORTS               NAMES
992baf6abefa        8522d622299c                                        "/opt/bin/flanneld -…"   2 minutes ago       Up 2 minutes                                   k8s_kube-flannel_kube-flannel-ds-rz2xj_kube-system_50c36e3b-0ad3-409c-a601-c8f85aa36428_0
78be74ae6cad        quay.io/coreos/flannel                              "cp -f /etc/kube-fla…"   2 minutes ago       Exited (0) 2 minutes ago                       k8s_install-cni_kube-flannel-ds-rz2xj_kube-system_50c36e3b-0ad3-409c-a601-c8f85aa36428_0
e30ad41e86d3        registry.aliyuncs.com/google_containers/pause:3.2   "/pause"                 3 minutes ago       Up 3 minutes                                   k8s_POD_kube-flannel-ds-rz2xj_kube-system_50c36e3b-0ad3-409c-a601-c8f85aa36428_0
72df4a6ccc2a        4a76fb49d490                                        "/usr/local/bin/kube…"   40 minutes ago      Up 40 minutes                                  k8s_kube-proxy_kube-proxy-c6fdx_kube-system_89fdfc40-c7c8-4152-91ac-94a45f83cb1d_0
ee455bc6ca60        registry.aliyuncs.com/google_containers/pause:3.2   "/pause"                 40 minutes ago      Up 40 minutes                                  k8s_POD_kube-proxy-c6fdx_kube-system_89fdfc40-c7c8-4152-91ac-94a45f83cb1d_0
802350660d95        8f1e66e40394                                        "kube-scheduler --au…"   40 minutes ago      Up 40 minutes                                  k8s_kube-scheduler_kube-scheduler-master-1_kube-system_0b7a3f4a1ea56044c3ad536d56a87725_0
ee4008c4f1d5        a8fd6520f73d                                        "kube-controller-man…"   40 minutes ago      Up 40 minutes                                  k8s_kube-controller-manager_kube-controller-manager-master-1_kube-system_6f065f021a2517457fa9368ab63b44f2_0
effb22b25ffa        registry.aliyuncs.com/google_containers/pause:3.2   "/pause"                 40 minutes ago      Up 40 minutes                                  k8s_POD_kube-scheduler-master-1_kube-system_0b7a3f4a1ea56044c3ad536d56a87725_0
60930447b83b        registry.aliyuncs.com/google_containers/pause:3.2   "/pause"                 40 minutes ago      Up 40 minutes                                  k8s_POD_kube-controller-manager-master-1_kube-system_6f065f021a2517457fa9368ab63b44f2_0
d85b5859f2bb        1a4f1f05177f                                        "kube-apiserver --ad…"   41 minutes ago      Up 41 minutes                                  k8s_kube-apiserver_kube-apiserver-master-1_kube-system_7fb363525d550d682b33d84cb74dda9d_0
61ee22184e58        registry.aliyuncs.com/google_containers/pause:3.2   "/pause"                 41 minutes ago      Up 41 minutes                                  k8s_POD_kube-apiserver-master-1_kube-system_7fb363525d550d682b33d84cb74dda9d_0
d0fc20c3ba74        0369cf4303ff                                        "etcd --advertise-cl…"   41 minutes ago      Up 41 minutes                                  k8s_etcd_etcd-master-1_kube-system_d9c8fc0f468e5e6013762f18eeab5cda_0
fdc7cad113c4        registry.aliyuncs.com/google_containers/pause:3.2   "/pause"                 41 minutes ago      Up 41 minutes                                  k8s_POD_etcd-master-1_kube-system_d9c8fc0f468e5e6013762f18eeab5cda_0


##### master:
[root@master-1 ~]# kubeadm token list
TOKEN                     TTL         EXPIRES                     USAGES                   DESCRIPTION                                                EXTRA GROUPS
cdeix4.h84buwepsp1yx14v   23h         2021-09-23T12:04:22+08:00   authentication,signing   The default bootstrap token generated by 'kubeadm init'.   system:bootstrappers:kubeadm:default-node-token



##### master:
[root@master-1 ~]# kubectl get node -o wide
NAME       STATUS   ROLES    AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION           CONTAINER-RUNTIME
master-1   Ready    master   42m   v1.19.9   172.16.201.134   <none>        CentOS Linux 7 (Core)   3.10.0-1160.el7.x86_64   docker://19.3.13
node-1     Ready    <none>   26m   v1.19.9   172.16.201.135   <none>        CentOS Linux 7 (Core)   3.10.0-1160.el7.x86_64   docker://19.3.13
node-2     Ready    <none>   25m   v1.19.9   172.16.201.136   <none>        CentOS Linux 7 (Core)   3.10.0-1160.el7.x86_64   docker://19.3.13




##### master:问题：健康检查错误：
[root@master-1 ~]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                       ERROR
scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused   
controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused   
etcd-0               Healthy     {"health":"true"}    

解：
cd /etc/kubernetes/manifests/
[root@master-1 manifests]# vim kube-controller-manager.yaml
[root@master-1 manifests]# vim kube-scheduler.yaml 
2个文件的    - --port=0 注释掉后等一会



[root@master-1 manifests]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
[root@master-1 manifests]# 


[root@master-1 manifests]# kubectl get ns
NAME              STATUS   AGE
default           Active   47m
kube-node-lease   Active   47m
kube-public       Active   47m
kube-system       Active   47m



#### 5、 测试kubernetes集群
######1、安装nginx来测试


[root@master-1 ~]# kubectl create deployment nginx --image=nginx
deployment.apps/nginx created
[root@master-1 ~]# kubectl expose deployment nginx --port=80 --type=NodePort
service/nginx exposed


[root@master-1 ~]# kubectl get pod,svc -o wide
NAME                         READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
pod/nginx-6799fc88d8-lkmk7   1/1     Running   0          3m53s   10.244.2.5   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
service/kubernetes   ClusterIP   10.1.0.1      <none>        443/TCP        6h50m   <none>
service/nginx        NodePort    10.1.198.44   <none>        80:30698/TCP   2m28s   app=nginx

####得到service端口转换后的端口为：80:30698


######访问效果测试：
[root@master-1 ~]# curl -I -m 10 -o /dev/null -s -w %{http_code} http://172.16.201.134:30698/
200
[root@master-1 ~]# curl -I -m 10 -o /dev/null -s -w %{http_code} http://172.16.201.135:30698/
200
[root@master-1 ~]# curl -I -m 10 -o /dev/null -s -w %{http_code} http://172.16.201.136:30698/
200


######2、测试扩容情况（扩容到3个副本）
[root@master-1 ~]# kubectl scale deployment nginx --replicas=3
deployment.apps/nginx scaled
[root@master-1 ~]# 


[root@master-1 ~]# kubectl get pod,svc -o wide
NAME                         READY   STATUS              RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
pod/nginx-6799fc88d8-c25s6   0/1     ContainerCreating   0          16s     <none>       node-1   <none>           <none>
pod/nginx-6799fc88d8-lkmk7   1/1     Running             0          9m34s   10.244.2.5   node-2   <none>           <none>
pod/nginx-6799fc88d8-xwjqr   0/1     ContainerCreating   0          16s     <none>       node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
service/kubernetes   ClusterIP   10.1.0.1      <none>        443/TCP        6h56m   <none>
service/nginx        NodePort    10.1.198.44   <none>        80:30698/TCP   8m9s    app=nginx


[root@master-1 ~]# kubectl get pod,svc -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
pod/nginx-6799fc88d8-c25s6   1/1     Running   0          50s   10.244.1.4   node-1   <none>           <none>
pod/nginx-6799fc88d8-lkmk7   1/1     Running   0          10m   10.244.2.5   node-2   <none>           <none>
pod/nginx-6799fc88d8-xwjqr   1/1     Running   0          50s   10.244.2.6   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
service/kubernetes   ClusterIP   10.1.0.1      <none>        443/TCP        6h56m   <none>
service/nginx        NodePort    10.1.198.44   <none>        80:30698/TCP   8m43s   app=nginx



[root@master-1 ~]# kubectl get pods  --all-namespaces -o wide        
NAMESPACE              NAME                                         READY   STATUS    RESTARTS   AGE     IP               NODE       NOMINATED NODE   READINESS GATES
default                nginx-6799fc88d8-c25s6                       1/1     Running   0          11m     10.244.1.4       node-1     <none>           <none>
default                nginx-6799fc88d8-lkmk7                       1/1     Running   0          20m     10.244.2.5       node-2     <none>           <none>
default                nginx-6799fc88d8-xwjqr                       1/1     Running   0          11m     10.244.2.6       node-2     <none>           <none>
kube-system            coredns-6d56c8448f-mp5lz                     1/1     Running   0          7h6m    10.244.1.2       node-1     <none>           <none>
kube-system            coredns-6d56c8448f-wnqxj                     1/1     Running   0          7h6m    10.244.2.2       node-2     <none>           <none>
kube-system            etcd-master-1                                1/1     Running   1          7h6m    172.16.201.134   master-1   <none>           <none>
kube-system            kube-apiserver-master-1                      1/1     Running   1          7h6m    172.16.201.134   master-1   <none>           <none>
kube-system            kube-controller-manager-master-1             1/1     Running   1          6h21m   172.16.201.134   master-1   <none>           <none>
kube-system            kube-flannel-ds-mmhsm                        1/1     Running   0          6h29m   172.16.201.135   node-1     <none>           <none>
kube-system            kube-flannel-ds-rz2xj                        1/1     Running   1          6h29m   172.16.201.134   master-1   <none>           <none>
kube-system            kube-flannel-ds-ts9fm                        1/1     Running   0          6h29m   172.16.201.136   node-2     <none>           <none>
kube-system            kube-proxy-bkck2                             1/1     Running   0          6h50m   172.16.201.135   node-1     <none>           <none>
kube-system            kube-proxy-c6fdx                             1/1     Running   1          7h6m    172.16.201.134   master-1   <none>           <none>
kube-system            kube-proxy-phjdh                             1/1     Running   0          6h50m   172.16.201.136   node-2     <none>           <none>
kube-system            kube-scheduler-master-1                      1/1     Running   1          6h21m   172.16.201.134   master-1   <none>           <none>
kubernetes-dashboard   dashboard-metrics-scraper-79c5968bdc-bcm4d   1/1     Running   0          5h1m    10.244.1.3       node-1     <none>           <none>
kubernetes-dashboard   kubernetes-dashboard-9f9799597-529zk         1/1     Running   0          5h1m    10.244.2.4       node-2     <none>           <none>







####查看顺序：
######查看 namespace信息：
[root@master-1 ~]# kubectl get namespace
NAME                   STATUS   AGE
default                Active   7h23m
kube-node-lease        Active   7h23m
kube-public            Active   7h23m
kube-system            Active   7h23m
kubernetes-dashboard   Active   5h17m

######查看namespace的service信息：
[root@master-1 ~]# kubectl get service -o wide --namespace=default
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
kubernetes   ClusterIP   10.1.0.1      <none>        443/TCP        7h22m   <none>
nginx        NodePort    10.1.198.44   <none>        80:30698/TCP   34m     app=nginx

另一种写法：
[root@master-1 ~]# kubectl get service/nginx
NAME    TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.1.198.44   <none>        80:30698/TCP   43m


######查看svc nginx日志
[root@master-1 ~]# kubectl describe svc nginx
Name:                     nginx
Namespace:                default
Labels:                   app=nginx
Annotations:              <none>
Selector:                 app=nginx
Type:                     NodePort
IP:                       10.1.198.44
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30698/TCP
Endpoints:                10.244.1.4:80,10.244.2.5:80,10.244.2.6:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
[root@master-1 ~]# 

######查看pod name
[root@master-1 ~]# kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
nginx-6799fc88d8-c25s6   1/1     Running   0          24m   10.244.1.4   node-1   <none>           <none>
nginx-6799fc88d8-lkmk7   1/1     Running   0          34m   10.244.2.5   node-2   <none>           <none>
nginx-6799fc88d8-xwjqr   1/1     Running   0          24m   10.244.2.6   node-2   <none>           <none>
[root@master-1 ~]# 
[root@master-1 ~]# 
[root@master-1 ~]# 

######查看pod nginx-6799fc88d8-c25s6 日志：
[root@master-1 ~]# kubectl describe pod nginx-6799fc88d8-c25s6
Name:         nginx-6799fc88d8-c25s6
Namespace:    default
Priority:     0
Node:         node-1/172.16.201.135
Start Time:   Wed, 22 Sep 2021 19:00:21 +0800
Labels:       app=nginx
              pod-template-hash=6799fc88d8
Annotations:  <none>
Status:       Running
IP:           10.244.1.4
IPs:
  IP:           10.244.1.4
Controlled By:  ReplicaSet/nginx-6799fc88d8
Containers:
  nginx:
    Container ID:   docker://5cf5621c44344d802efb5d3c565aeaf98ce7f67732c009a10d798bf9919737d4
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:853b221d3341add7aaadf5f81dd088ea943ab9c918766e295321294b035f3f3e
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 22 Sep 2021 19:00:55 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-b4d9n (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-b4d9n:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-b4d9n
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  25m   default-scheduler  Successfully assigned default/nginx-6799fc88d8-c25s6 to node-1
  Normal  Pulling    25m   kubelet            Pulling image "nginx"
  Normal  Pulled     24m   kubelet            Successfully pulled image "nginx" in 32.403763647s
  Normal  Created    24m   kubelet            Created container nginx
  Normal  Started    24m   kubelet            Started container nginx



docker exec -it 5cf5621c4434 /bin/bash

######删除nginx：
[root@master-1 ~]# kubectl get deployment
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   3/3     3            3           21h
[root@master-1 ~]# kubectl delete deployment nginx 
deployment.apps "nginx" deleted

[root@master-1 ~]# kubectl get deployment
No resources found in default namespace.

[root@master-1 ~]# kubectl delete service nginx
service "nginx" deleted

[root@master-1 ~]#  kubectl get pod,svc -o wide        
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.1.0.1     <none>        443/TCP   28h   <none>
