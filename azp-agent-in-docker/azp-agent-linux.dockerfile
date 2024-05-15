FROM ubuntu:22.04

ARG TERRAFORM_VER=1.8.3

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
