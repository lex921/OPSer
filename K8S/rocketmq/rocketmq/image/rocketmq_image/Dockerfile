FROM centos:latest
 
RUN rm -f /etc/localtime \
&& ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone
 
ENV LANG en_US.UTF-8
ADD jdk-8u311-linux-x64.tar.gz /usr/local/
ADD rocketmq-4.9.2.tar.gz /usr/local/
RUN mkdir -p /data/rocketmq/store
ENV JAVA_HOME=/usr/local/jdk1.8.0_311
ENV CLASSPATH=.$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH=$JAVA_HOME/bin:$PATH

CMD ["/bin/bash"]
