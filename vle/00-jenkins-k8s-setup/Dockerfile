# Jenkins with Docker CLI, kubectl, Node.js, Trivy - used by VLE 7, 8, 9
# One download per layer + retries, so a flaky network only redoes the step that failed (cached layers are reused).
FROM jenkins/jenkins:lts-jdk17
USER root
ARG CURL="curl -fsSL --retry 6 --retry-all-errors --retry-delay 5"
RUN apt-get -o Acquire::Retries=6 update \
 && apt-get -o Acquire::Retries=6 install -y --no-install-recommends ca-certificates curl gnupg git \
 && rm -rf /var/lib/apt/lists/*
RUN install -m 0755 -d /etc/apt/keyrings \
 && $CURL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list
RUN $CURL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource.sh && bash /tmp/nodesource.sh && rm /tmp/nodesource.sh
RUN apt-get -o Acquire::Retries=6 update \
 && apt-get -o Acquire::Retries=6 install -y --no-install-recommends docker-ce-cli nodejs \
 && rm -rf /var/lib/apt/lists/*
RUN $CURL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl" && chmod +x /usr/local/bin/kubectl
RUN $CURL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh -o /tmp/trivy.sh \
 && for i in 1 2 3 4; do sh /tmp/trivy.sh -b /usr/local/bin && break; sleep 5; done && rm /tmp/trivy.sh && trivy --version
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN for i in 1 2 3 4; do jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt && break; echo "plugin download retry $i"; sleep 10; done
USER jenkins
