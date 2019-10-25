FROM hashicorp/terraform:light as terraform

FROM jenkins/jnlp-agent-docker:latest

ENV MAVEN_VERSION 3.6.3
ENV MAVEN_HOME /usr/lib/mvn
ENV NODE_HOME /usr/local/lib/nodejs/node-v14.15.3-linux-x64/bin
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk/
ENV PATH $MAVEN_HOME/bin:$NODE_HOME:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER root

# Install Java
RUN apk update && apk add -u openjdk11

# Install Node and Angular
RUN wget https://nodejs.org/dist/v14.15.3/node-v14.15.3-linux-x64.tar.xz && \
  mkdir -p /usr/local/lib/nodejs && \
  tar -xJvf node-v14.15.3-linux-x64.tar.xz -C /usr/local/lib/nodejs && \
  npm install -g @angular/cli

# Install AWS Cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf ./aws

# Install Maven
RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  tar -zxvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  mv apache-maven-$MAVEN_VERSION /usr/lib/mvn

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
  chmod 700 get_helm.sh && \
  ./get_helm.sh && \
  rm ./get_helm.sh

USER jenkins

COPY --from=terraform /bin/terraform /bin/terraform

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
