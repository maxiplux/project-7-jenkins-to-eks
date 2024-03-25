# Use the latest Ubuntu as the base image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update apt repository and install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    lsb-release \
    wget \
    curl \
    gnupg \
    ca-certificates \
    sudo  # Adding sudo in case it's not in the base image



# Install Java 17 using OpenJDK
RUN apt-get update && apt-get install -y openjdk-17-jdk

# Install Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get update && apt-get install -y python3.11



RUN apt-get -y install ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN  chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
RUN echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN sudo apt-get update -y


# Add the Jenkins repository key and repository
RUN sudo apt-get install -y python3-pip curl unzip pip mc htop lynx net-tools docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



# Set Python 3.11 as the default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Install Jenkins



RUN  wget -O /usr/share/keyrings/jenkins-keyring.asc   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
RUN echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
RUN apt-get update
RUN apt-get install -y jenkins

RUN cd /tmp && curl -LO  https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv kubectl /usr/local/bin

RUN cd /tmp && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sh ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
ENV JENKINS_PORT=8081

#RUN systemctl enable jenkins
RUN sysctl -w fs.file-max=500000
#RUN /etc/init.d/jenkins start
RUN  service  jenkins start


# Verify installations
RUN java -version
RUN docker --version
RUN python3.11 --version
RUN jenkins --version

#RUN setfacl -m user:$USER:rw /var/run/docker.sock
RUN sudo usermod -aG docker jenkins
RUN sudo touch  /var/run/docker.sock && sudo chown jenkins:jenkins /var/run/docker.sock
RUN sudo chmod a+rwx /var/run/docker.sock
#RUN sudo chmod 777 /var/run/docker.sock



# Expose the default Jenkins port
EXPOSE 8080

# Expose the Jenkins JNLP port for agent connections
EXPOSE 50000


# Set the default command
# Set Jenkins to run as the entrypoint

CMD ["tail", "-f", "/dev/null"]
#docker buildx build --platform=linux/arm64,linux/amd64 --push --tag maxiplux/jenkins:1.0.5 -f ./Dockerfile .
#Get-Content password1.txt | docker login --username maxiplux --password-stdin
