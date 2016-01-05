FROM java:8-jdk

MAINTAINER Josh McDade <josh.ncsu@gmail.com>

ENV JENKINS_SWARM_VERSION 2.0
ENV HOME /home/jenkins
ENV DOCKER_COMPOSE_VERSION 1.5.2

RUN apt-get update && \
  apt-get install -y sudo && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -c "Jenkins slave user" -d $HOME -m jenkins
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
  && chmod 755 /usr/share/jenkins && \
  sh -c 'echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers'

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
RUN chown jenkins:jenkins /usr/local/bin/jenkins-slave.sh && \
  chmod 0777 /usr/local/bin/jenkins-slave.sh && \
  groupadd -g 233 docker && \
  usermod -a -G docker jenkins && \
  curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/run.sh > /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

# ↑↑↑ 233 is the GID for the docker group on CoreOS - this gives the jenkins permission to read that socket

USER jenkins
WORKDIR /home/jenkins
VOLUME /home/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
