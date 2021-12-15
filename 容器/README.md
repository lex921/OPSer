## 镜像官网
### Docker镜像官网（Docker Hub）:
https://hub.docker.com

### 搜索镜像地址：
https://hub.docker.com/search?q=&type=image&image_filter=official

### 阿里云容器Hub：
https://dev.aliyun.com


## 操作系统基础镜像        
比如你要从Linux操作系统基础镜像开始构建，可以参考下表来选择合适的基础镜像：

1、busybox：大小：1.15MB	临时测试用        
2、alpine：大小：4.41MB	主要用于测试，也可用于生产环境            
3、centos：大小：200MB	  主要用于生产环境，支持CentOS/Red Hat，常用于追求稳定性的企业应用        
4、ubuntu：大小：81.1MB	主要用于生产环境，常用于人工智能计算和企业应用       
5、debian：大小：101MB	  主要用于生产环境       

## 镜像
busybox
* 描述：可以将busybox理解为一个超级简化版嵌入式Linux系统。
* 官网：https://www.busybox.net/
* 镜像：https://hub.docker.com/_/busybox/
* 包管理命令：apk, lbu

Alpine
* 描述：Alpine是一个面向安全的、轻量级的Linux系统，基于musl libc和busybox。
* 官网：https://www.alpinelinux.org/
* 镜像：https://hub.docker.com/_/alpine/
* 包管理命令：apk, lbu

CentOS
* 描述：可以理解CentOS是RedHat的社区版
* 官网：https://www.centos.org/
* 镜像：https://hub.docker.com/_/centos/
* 包管理命令：yum, rpm

Ubuntu
* 描述：另一个非常出色的Linux发行版
* 官网：http://www.ubuntu.com/
* 镜像：https://hub.docker.com/_/ubuntu/
* 包管理命令：apt-get, dpkg

Debian
* 描述：另一个非常出色的Linux发行版
* 官网：https://www.debian.org/
* 镜像：https://hub.docker.com/_/debian/
* 包管理命令：apt-get, dpkg

## 编程语言基础镜像
Java基础镜像
* https://hub.docker.com/_/java/ （Deprecated)
* https://hub.docker.com/_/openjdk/
由于Oracle JDK license问题，Docker官方的Java基础镜像使用的是OpenJDK而不是Oracle JDK。

Python基础镜像
* https://hub.docker.com/_/python/

NodeJs基础镜像
* https://hub.docker.com/_/node/

Go基础镜像
* https://hub.docker.com/_/golang

## 应用基础镜像
Nginx基础镜像
* https://hub.docker.com/_/nginx/

Tomcat基础镜像
* https://hub.docker.com/_/tomcat/

Jetty基础镜像
* https://hub.docker.com/_/jetty/

## 其它基础镜像例子
Maven基础镜像
* https://hub.docker.com/_/maven/

Jenkins基础镜像
* https://hub.docker.com/r/jenkins/jenkins/

GitLab基础镜像
* https://hub.docker.com/r/gitlab/gitlab-ce/
