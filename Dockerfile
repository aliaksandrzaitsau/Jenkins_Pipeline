FROM centos
RUN yum install -y maven

# JAVA 10
RUN yum install -y wget && \
    cd /opt && \
    wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/11.0.1+13/90cf5d8f270a4347a95050320eef3fb7/jdk-11.0.1_linux-x64_bin.tar.gz && \
    tar zxvf jdk-11.0.1_linux-x64_bin.tar.gz && \
    rm -f jdk-11.0.1_linux-x64_bin.tar.gz
ENV JAVA_HOME=/opt/jdk-11.0.1
ENV PATH="$JAVA_HOME/bin:$PATH"
