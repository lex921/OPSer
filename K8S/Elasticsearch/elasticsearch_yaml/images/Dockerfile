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

ADD elasticsearch-7.6.2-linux-x86_64.tar.gz /opt
 
 
RUN mkdir -p /opt/elasticsearch-7.6.2/data \
&& mkdir -p /opt/elasticsearch-7.6.2/logs \
&& useradd elasticsearch \
&& chown -R elasticsearch:elasticsearch /opt \
&& chmod -R 777 /opt \
&& setfacl -R -m u:elasticsearch:rwx /opt \
&& setfacl -R -m u:elasticsearch:rwx /opt \
&& rm -f /opt/elasticsearch-7.6.2/config/elasticsearch.yml
 
COPY elasticsearch.yml /opt/elasticsearch-7.6.2/config/
 
USER elasticsearch
 
EXPOSE 9200 9300
CMD ["/opt/elasticsearch-7.6.2/bin/elasticsearch"]
