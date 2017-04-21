FROM ubuntu:trusty
MAINTAINER anatoliytihomirov@yahoo.com

# ENV section
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# add tomcat user and group
RUN groupadd tomcat && \
    mkdir -p /opt/tomcat && \
    useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# change workdir
WORKDIR /opt/tomcat

# download and unpack archive
ADD http://apache.mirrors.ionfish.org/tomcat/tomcat-7/v7.0.77/bin/apache-tomcat-7.0.77.tar.gz /opt/tomcat
RUN tar -xzvf apache-tomcat-7.0.77.tar.gz && \
    rm -f apache-tomcat-7.0.77.tar.gz

# set tomcat files permissions
COPY tomcat_envvars /opt/tomcat
RUN chgrp -R tomcat /opt/tomcat && \
    chmod -R g+r conf && \
    chmod g+x conf && \
    chown -R tomcat webapps/ work/ temp/ logs/

# install supervisor, oracle jdk8 and apache
RUN add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y apache2 \
                       supervisor \
                       oracle-java8-installer

# as described here: https://docs.docker.com/engine/admin/using_supervisord/#adding-supervisors-configuration-file
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

# copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8080

CMD ["/usr/bin/supervisord"]
