
# CentOS7+Doker19.03.13 + K8S1.19.9 安装


## 重要概念
1、cluster是 计算、存储和网络资源的集合，k8s利用这些资源运行各种基于容器的应用。   
2、master是cluster的大脑，他的主要职责是调度，即决定将应用放在那里运行。master运行linux操作系统，可以是物理机或者虚拟机。为了实现高可用，可以运行多个master。     
3、node的职责是运行容器应用。node由master管理，node负责监控并汇报容器的状态，同时根据master的要求管理容器的生命周期。node运行在linux的操作系统上，可以是物理机或者是虚拟机。     
4、pod是k8s的最小工作单元。每个pod包含一个或者多个容器。pod中的容器会作为一个整体被master调度到一个node上运行。       
5、controller k8s通常不会直接创建pod,而是通过controller来管理pod的。controller中定义了pod的部署特性，比如有几个剧本，在什么样的node上运行等。为了满足不同的业务场景，k8s提供了多种controller，包括deployment、replicaset、daemonset、statefulset、job等。     
6、deployment是最常用的controller。deployment可以管理pod的多个副本，并确保pod按照期望的状态运行。      
7、replicaset实现了pod的多副本管理。使用deployment时会自动创建replicaset，也就是说deployment是通过replicaset来管理pod的多个副本的，我们通常不需要直接使用replicaset。     
8、daemonset用于每个node最多只运行一个pod副本的场景。正如其名称所示的，daemonset通常用于运行daemon。     
9、statefuleset能够保证pod的每个副本在整个生命周期中名称是不变的，而其他controller不提供这个功能。当某个pod发生故障需要删除并重新启动时，pod的名称会发生变化，同时statefulset会保证副本按照固定的顺序启动、更新或者删除。     
10、job用于运行结束就删除的应用，而其他controller中的pod通常是长期持续运行的。     
11、service k8s的 service定义了外界访问一组特定pod的方式。service有自己的IP和端口，service为pod提供了负载均衡。    
k8s运行容器pod与访问容器这两项任务分别由controller和service执行。      
12、namespace 可以将一个物理的cluster逻辑上划分成多个虚拟cluster，每个cluster就是一个namespace。不同的namespace里的资源是完全隔离的。     


## 一、基础环境准备：

centos7.9:
172.16.201.134  master-1
172.16.201.135  node-1
172.16.201.136  node-2


#### 1、设置主机名
echo '
172.16.201.134  master-1
172.16.201.135  node-1
172.16.201.136  node-2' >> /etc/hosts

hostnamectl set-hostname master-1
hostnamectl set-hostname node-1
hostnamectl set-hostname node-2


#### 2、关闭防火墙
systemctl stop firewalld && systemctl disable firewalld

#### 3、关闭selinux
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
[root@master-1 ~]# sestatus
SELinux status:                 disabled

#### 4、关闭swap
swapoff -a
vim /etc/fstab
#####/dev/mapper/centos-swap swap                    swap    defaults        0 0

#### 5、安装ntp
yum -y install ntp
systemctl enable ntpd
systemctl restart ntpd

crontab -e
*/10 * * * * ntpdate 1.cn.pool.ntp.org

#### 6、将桥接的IPV4流量传递到iptables 的链
[root@master-1 ~]# cat > /etc/sysctl.d/k8s.conf << EOF
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-call-iptables = 1
> EOF

[root@master-1 ~]# cat /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

[root@master-1 ~]# sysctl --system    
* Applying /usr/lib/sysctl.d/00-system.conf ...
* Applying /usr/lib/sysctl.d/10-default-yama-scope.conf ...
kernel.yama.ptrace_scope = 0
* Applying /usr/lib/sysctl.d/50-default.conf ...
kernel.sysrq = 16
kernel.core_uses_pid = 1
kernel.kptr_restrict = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.all.promote_secondaries = 1
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.d/99-sysctl.conf ...
* Applying /etc/sysctl.d/k8s.conf ...
* Applying /etc/sysctl.conf ...


#### 7、安装Docker
##### 1）设置镜像的仓库
[root@master-1 yum.repos.d]# cd /etc/yum.repos.d/            
[root@master-1 yum.repos.d]# wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo        

##### 2）安装docker
[root@master-1 yum.repos.d]# yum install -y yum-utils device-mapper-persistent-data lvm2​          

[root@master-1 yum.repos.d]# yum install docker-ce-19.03.13 docker-ce-cli-19.03.13 containerd.io     

指定安装的docker版本为19.03.13

##### 3)启动
[root@master ~] systemctl start docker

##### 4)配置systemd服务
[root@master-1 system]# cd  /usr/lib/systemd/system/       
[root@master-1 system]# vim docker.service      
[Unit]     
Description=Docker Application Container Engine     
Documentation=https://docs.docker.com       
After=network-online.target firewalld.service      
Wants=network-online.target      

[Service]     
Type=notify       

ExecStart=/usr/bin/dockerd     
ExecReload=/bin/kill -s HUP $MAINPID     
LimitNOFILE=infinity        
LimitNPROC=infinity       
LimitCORE=infinity      

TimeoutStartSec=0  
Delegate=yes       
KillMode=process     
Restart=on-failure       
StartLimitBurst=3     
StartLimitInterval=60s      
      
[Install]    
WantedBy=multi-user.target       


[root@master-1 system]# vim  docker.service     
[Unit]     
Description=Docker Application Container Engine  
Documentation=https://docs.docker.com       
After=network-online.target firewalld.service     
Wants=network-online.target      

[Service]      
Type=notify     
ExecStart=/usr/bin/dockerd      
ExecReload=/bin/kill -s HUP $MAINPID      
LimitNOFILE=infinity      
LimitNPROC=infinity       
LimitCORE=infinity      
TimeoutStartSec=0      
Delegate=yes    
KillMode=process       
Restart=on-failure     
StartLimitBurst=3       
StartLimitInterval=60s    

[Install]            
WantedBy=multi-user.target          

###### 5)启动一套
[root@master-1 system]# systemctl daemon-reload              
[root@master-1 system]# systemctl enable docker.service                   
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /etc/systemd/system/docker.service.          

[root@master-1 system]# ps -aux | grep dockerd      
root       1670  0.2  3.6 591900 67708 ?        Ssl  10:52   0:00 /usr/bin/dockerd

[root@master-1 system]# systemctl status docker     
● docker.service - Docker Application Container Engine           
   Loaded: loaded (/etc/systemd/system/docker.service; enabled; vendor preset: disabled)      
   Active: active (running) since Wed 2021-09-22 10:52:20 CST; 3min 51s ago      
     Docs: https://docs.docker.com      
 Main PID: 1670 (dockerd)       
   CGroup: /system.slice/docker.service         
           ├─1670 /usr/bin/dockerd        
           └─1677 containerd --config /var/run/docker/containerd/containerd.toml --log-level info       

##### 6)镜像加速
[root@master-1 system]# cd /etc/docker       
[root@master-1 docker]# vim daemon.json                  
{             
"registry-mirrors": ["https://23h04een.mirror.aliyuncs.com"]                    
}           

##### 7)查看版本      
[root@master-1 docker]# docker version      
Client: Docker Engine - Community     
 Version:           19.03.13     
 API version:       1.40         
 Go version:        go1.13.15          
 Git commit:        4484c46d9d             
 Built:             Wed Sep 16 17:03:45 2020     
 OS/Arch:           linux/amd64      
 Experimental:      false       

Server: Docker Engine - Community       
 Engine:
  Version:          19.03.13       
  API version:      1.40 (minimum version 1.12)      
  Go version:       go1.13.15     
  Git commit:       4484c46d9d       
  Built:            Wed Sep 16 17:02:21 2020     
  OS/Arch:          linux/amd64    
  Experimental:     false 
 containerd:     
  Version:          1.4.9                 
  GitCommit:        e25210fe30a0a703442421b0f60afac609f950a3       
 runc:       
  Version:          1.0.1       
  GitCommit:        v1.0.1-0-g4144b63      
 docker-init:             
  Version:          0.18.0       
  GitCommit:        fec3683       
[root@master-1 docker]#          

##### 8)测试
[root@master-1 docker]# docker pull hello-world            
Using default tag: latest      
latest: Pulling from library/hello-world      
b8dfde127a29: Pull complete           
Digest: sha256:61bd3cb6014296e214ff4c6407a5a7e7092dfa8eefdbbec539e133e97f63e09f        
Status: Downloaded newer image for hello-world:latest      
docker.io/library/hello-world:latest           
         
[root@master-1 docker]# docker run hello-world         

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

[root@master-1 docker]#                    
若是出现了上图的内容则说明hello-world运行成功。

##### 9)配置免密        
分别复制key到master         
[root@node-1 .ssh]# ssh-copy-id root@172.16.201.134     
[root@node-2 .ssh]# ssh-copy-id root@172.16.201.134            

分别复制key到node-1、node-2     
[root@master-1 .ssh]#  ssh-copy-id root@172.16.201.135
[root@master-1 .ssh]#  ssh-copy-id root@172.16.201.136


master：       
[root@master-1 .ssh]# cat authorized_keys            
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0Z5AFJNpJMy/dKI39iGMUOVOMGiczhzqdnRKLX2ikyPrAHpXCdOz+3nhXE4m3V1pGWo9gXZNyUG8b2cqtVHLCLGsq4j1qTB9JqVBsWl0kE137E5UEJ0bs9OoKMofeiBQhKPTbS9uCoTrJbJHLr0DAFEE30EYmMtq6thPkTn6eTAzaMHfVH16b76orOLYQ1SWKYPrFMAAz8uDBQ8ncbslneYJF9K9rVHVzNdLJ5/FUmygI2sKXwVpcH7DwpuNK0wPOrMlp0HWeeVeaBoW73POi3Gd2ON7NUP37/U6veai6p7HbAU7AuteUdQlhdE8sj9kD49aDQCwuv4UkEFzuPRO1 root@node-1         
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5EpSsO0h0nfj3kTAKkF/IW5MnmWBN0W3SAw26lh51K/TVmt9v6nvESpqiD1NkSFpNxqx77JljDI0N6fwZN8V3+FyPKU863fPZT0WU1KlwLUp70yCRXjpyO1QaT/f1sdlPs+Tkrair2vXbav41snbT5/2Sze3QiNUMS/Z6g3RfwpXmmd5epetp3VwwkGdrJGt1LDrPnE+YUx8rjQknv1rZCJISXsejdeQFDA01/CPFQxt1Qhu/uhywS2g+qIZPbxf/vBdm779x2q/ctX+3bjnaPmZdaIXG2JRgD5a//f0Uur/wjVHwrJzgPbo9GIE4dGdP8dW7Ni04Uym4aL9q2Iv5 root@node-2          

##### 10)测试
[root@node-2 .ssh]# ssh root@172.16.201.134         
Last login: Wed Sep 22 11:14:30 2021 from 172.16.201.1       
[root@master-1 ~]# exit      
[root@node-2 .ssh]#       

master：      
[root@master-1 ~]# ssh root@172.16.201.136       
Last login: Wed Sep 22 11:14:35 2021 from 172.16.201.1      
[root@node-2 ~]# exit       
logout
Connection to 172.16.201.136 closed.       
[root@master-1 ~]# ssh root@172.16.201.135      
Last login: Wed Sep 22 11:14:33 2021 from 172.16.201.1           
[root@node-1 ~]# exit       
logout                 
Connection to 172.16.201.135 closed.            
