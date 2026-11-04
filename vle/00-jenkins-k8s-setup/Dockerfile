# Jenkins with Docker CLI, kubectl, Node.js, Trivy - used by VLE 7, 8, 9
FROM jenkins/jenkins:lts-jdk17
USER root
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg git \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli nodejs \
 && curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl" && chmod +x /usr/local/bin/kubectl \
 && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin \
 && rm -rf /var/lib/apt/lists/*
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
USER jenkins
