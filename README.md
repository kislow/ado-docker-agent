# Azure DevOps linux docker agent

Run a self hosted azure devops agent in docker.

## Prerequisite

- azure linux vm
- docker
- internet connectivity
- vm network config
- az cli
- Azure DevOps Agent Pool
- Azure DevOps Personal Access Token

## Getting Started

Installing required binaries:

```sh
# install az cli using a single command
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
```

```sh
# install docker on vm
./docker_install.sh
```

```sh
# clone repository
git@github.com:kislow/ado-docker-agent.git
```

## Setting up docker agent in linux vm

```sh
# create new dir
mkdir ~/azp-agent-in-docker/
# cd into new dir
cd ~/azp-agent-in-docker/

# copy files into newly created dir
cp azp-agent-linux.dockerfile start.sh
```

## Build docker image

```sh
# ensure terraform version is specified
docker build --build-arg TERRAFORM_VER=1.8.3 --tag "azp-agent:linux" --file "./azp-agent-linux.dockerfile" .
```

## Push to your registry

**Optional:**

```sh
docker tag azp-agent:linux <YOUR_REGISTRY_USERNAME>/azp-agent:linux
docker push <YOUR_REGISTRY_USERNAME>/azp-agent:linux
```

## Running docker single container

```sh
docker run -d -e AZP_URL="https://dev.azure.com/ABC/XYZ" \ 
                -e AZP_TOKEN="XXXXXXX" -e AZP_POOL="qwerty" \ 
                -e AZP_AGENT_NAME="kislow-linux-docker-agent1" \ 
                --name "azp-agent-linux" azp-agent:linux`
```
## Running multiple containers (agents)

```sh
# create a .env file and ensure it resides in same dir as docker-compose.yml file
touch .env

# ensure data is updated accordingly
cat <<EOF > .env
AZP_URL="https://dev.azure.com/ABC"
AZP_TOKEN="XXXXXXXXXXXXXXXXXXXXX"
AZP_POOL="QWERTY"
EOF
```

```sh
# start multiple containers
docker compose up -d --scale azp-agent=${AGENT_COUNT}

# stop/remove containers
docker compose down
```

## Azure Deployment

```sh
az vm create \
  --resource-group my-ado-agents-rg \
  --name ado-agent-vm01 \
  --image Canonical:ubuntu-24_04-lts:server:latest \
  --size Standard_B2s \
  --admin-username ubuntu \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --custom-data cloud-init.yml \
  --public-ip-address ""
```

For in depth documentation pleas refer to the [Official Microsoft Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#linux).
