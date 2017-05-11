FROM jenkins
USER root

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
RUN apt-get install curl -y

# install arc
RUN apt-get install -y php5 php5-curl
RUN mkdir /phabricator
RUN git clone https://github.com/phacility/libphutil.git /phabricator/libphutil
RUN git clone https://github.com/phacility/arcanist.git /phabricator/arcanist
RUN chown -R jenkins:jenkins /phabricator

# # install docker cli client
RUN wget -P / -O docker.tgz https://get.docker.com/builds/Linux/x86_64/docker-17.05.0-ce.tgz
RUN tar xzvf /docker.tgz -C /
RUN chmod +x /docker/docker
RUN chown jenkins:jenkins /docker/docker
RUN cp /docker/docker /usr/local/bin/docker
RUN rm -rf /docker.tgz /docker

# install kubectl
RUN cd / && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x /kubectl
RUN chown jenkins:jenkins /kubectl
RUN mv /kubectl /usr/local/bin/kubectl


USER jenkins
ENV PATH="${PATH}:/phabricator/arcanist/bin/"
ENV DOCKER_HOST="tcp://docker:2375"
# pre-install plugins
COPY plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
