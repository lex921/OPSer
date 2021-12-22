FROM centos:latest
 
RUN rm -f /etc/localtime \
&& ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone
 
ENV LANG en_US.UTF-8
ENV MAVEN_HOME /usr/local/maven
ENV PATH $PATH:$MAVEN_HOME/bin
ENV JAVA_HOME=/usr/local/jdk1.8.0_311
ENV CLASSPATH=.$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH=$JAVA_HOME/bin:$PATH
 
ADD jdk-8u311-linux-x64.tar.gz /usr/local/
ADD rocketmq-externals.tar.gz /usr/local
ADD apache-maven-3.8.4-bin.tar.gz /usr/local
RUN mv /usr/local/apache-maven-3.8.4 /usr/local/maven
WORKDIR /usr/local/rocketmq-externals/rocketmq-console/
RUN mvn clean package -Dmaven.test.skip=true
 
 
WORKDIR /usr/local/rocketmq-externals/rocketmq-console/target
EXPOSE 8080
CMD ["nohup","java","-jar","rocketmq-console-ng-1.0.0.jar","&"]
