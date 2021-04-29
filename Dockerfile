# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.166.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

    ENV AWS_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt
    ENV REQUESTS_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt
    ENV PYTHONHTTPSVERIFY 0
    ENV USE_DOCKER_FILE_TO_CREATE_CONTAINER 1
    ENV BIN_DIR /usr/local/bin
    ENV PACKER_ZIP https://releases.hashicorp.com/packer/1.7.1/packer_1.7.1_linux_amd64.zip
    ENV TERRAGRUNT_BIN https://github.com/gruntwork-io/terragrunt/releases/download/v0.28.18/terragrunt_linux_amd64
    ENV TERRAFORM_ZIP https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
    ENV SAML2AWS_DOWNLOAD_URL https://github.com/Versent/saml2aws/releases/download/v2.27.1/saml2aws_2.27.1_linux_amd64.tar.gz
 
    RUN wget --no-check-certificate -P /usr/local/share/ca-certificates https://zscaler-pita.s3.amazonaws.com/ZscalerRootCertificate-2048-SHA256.crt && \
        update-ca-certificates

    RUN apt-get upgrade -y && \
        apt-get update && apt-get install -y \
        locales \
        tzdata

    RUN echo "America/New_York" | tee /etc/timezone && \
        ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
        dpkg-reconfigure -f noninteractive tzdata 

    RUN apt-get install -y \
        ca-certificates \
        git-core \
        python3 \
        python3-pip \
        unzip \
        wget \
        curl \
        vim \
        virtualenv \
        ruby \
        graphviz \
        && rm -rf /var/lib/apt/lists/*

    RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

    #Install SAML2AWS
    RUN curl -sSLo /tmp/saml2aws.tar.gz $SAML2AWS_DOWNLOAD_URL --insecure && \
        tar -xzvf /tmp/saml2aws.tar.gz -C $BIN_DIR && \
        chmod u+x $BIN_DIR && \
        saml2aws --version


    # Install Packer
    RUN curl -sSLo /tmp/packer.zip $PACKER_ZIP --insecure && \
        unzip /tmp/packer.zip -d $BIN_DIR && \
        rm /tmp/packer.zip

    # Install Terragrunt
    RUN curl -sSLo /tmp/terragrunt $TERRAGRUNT_BIN --insecure && \
        cp /tmp/terragrunt $BIN_DIR/terragrunt && \
        chmod +x $BIN_DIR/terragrunt && \
        rm /tmp/terragrunt 
    

    #Install Terraforming
    RUN git clone https://github.com/dtan4/terraforming.git /usr/local/share/terraforming && \
        gem install terraforming

    #Install Terraform
    RUN curl -sSLo /tmp/terraform.zip $TERRAFORM_ZIP --insecure && \
        unzip /tmp/terraform.zip -d $BIN_DIR && \
        rm /tmp/terraform.zip && \
        terraform --version 
