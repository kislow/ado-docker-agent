FROM ubuntu:22.04

ARG TERRAFORM_VER=1.14.0
ARG KUBECTL_VER=v1.34.0
ARG KUBELOGIN_VER=v0.2.13

RUN apt update -y && apt upgrade -y && \
    apt -y install curl \ 
                git \
                jq \
                libicu70 \
                python3 \
                python3-pip \
                zip \
                unzip \
                wget

RUN wget --no-show-progress https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform


# Install kubectl (Kubernetes CLI)
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl


RUN curl -LO https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VER}/kubelogin-linux-amd64.zip && \
    unzip kubelogin-linux-amd64.zip -d /azp && \
    chmod +x /azp/bin/linux_amd64/kubelogin && \
    mv /azp/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin && \
    rm kubelogin-linux-amd64.zip

# install azurecli with single command
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash


# Also can be "linux-arm", "linux-arm64".
ENV TARGETARCH="linux-x64"

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:agent /azp /home/agent

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]
