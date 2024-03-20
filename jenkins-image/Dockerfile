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
RUN sudo apt-get install -y pip docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



# Set Python 3.11 as the default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Install Jenkins



RUN  wget -O /usr/share/keyrings/jenkins-keyring.asc   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
RUN echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
RUN apt-get update
RUN apt-get install -y jenkins

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
RUN usermod -aG docker jenkins



# Expose the default Jenkins port
EXPOSE 8080

# Expose the Jenkins JNLP port for agent connections
EXPOSE 50000


# Set the default command
# Set Jenkins to run as the entrypoint
CMD ["tail", "-f", "/dev/null"]
#docker buildx build --platform=linux/arm64,linux/amd64 --push --tag maxiplux/jenkins:latest -f ./Dockerfile .