FROM alpine:3.20

LABEL maintainer="Roel de Cort"
LABEL version="0.1.0"

LABEL org.opencontainers.image.source="https://github.com/roelde/devops-cicd-runner"
LABEL org.opencontainers.image.description="A Docker image for running IAC tools CI/CD pipelines."
LABEL org.opencontainers.image.licenses="MIT"


# Tool versions
# renovate: datasource=github-releases depName=tofuutils/tenv
ENV TENV_VERSION=v3.2.4
# renovate: datasource=github-releases depName=hashicorp/terraform
ENV TERRAFORM_VERSION=1.9.7
# renovate: datasource=github-releases depName=opentofu/opentofu
ENV OPENTOFU_VERSION=1.8.3
# renovate: datasource=github-releases depName=pulumi/pulumi
ENV PULUMI_VERSION=v3.136.1
# renovate: datasource=repology depName=alpine_3_20/aws-cli versioning=loose
ENV AWS_CLI_VERSION=2.18.0-r0
# renovate: datasource=repology depName=alpine_3_20/ansible versioning=loose
ENV ANSIBLE_VERSION=10.5.0-r0
# renovate: datasource=repology depName=alpine_3_20/bash versioning=loose
ENV BASH_VERSION=5.2.26-r0
# renovate: datasource=repology depName=alpine_3_20/jq versioning=loose
ENV JQ_VERSION=1.7.1-r0
# renovate: datasource=repology depName=alpine_3_20/git versioning=loose
ENV GIT_VERSION=2.45.2-r0
# renovate: datasource=repology depName=alpine_3_20/python versioning=loose
ENV PYTHON_VERSION=3.12.7-r0
# renovate: datasource=repology depName=alpine_3_20/py3-pip versioning=loose
ENV PY3_PIP_VERSION=24.2-r1
# renovate: datasource=repology depName=alpine_3_20/shadow versioning=loose
ENV SHADOW_VERSION=4.16.0-r1
# renovate: datasource=repology depName=alpine_3_20/doas versioning=loose
ENV DOAS_VERSION=6.8.2-r7
# renovate: datasource=repology depName=alpine_3_20/curl versioning=loose
ENV CURL_VERSION=8.10.1-r0
# renovate: datasource=repology depName=alpine_3_20/tar versioning=loose
ENV TAR_VERSION=1.35-r2
# renovate: datasource=repology depName=alpine_3_20/unzip versioning=loose
ENV UNZIP_VERSION=6.0-r14

# Install required packages
RUN apk add --no-cache \
    bash=${BASH_VERSION} \
    git=${GIT_VERSION} \
    jq=${JQ_VERSION} \
    python3=${PYTHON_VERSION} \
    py3-pip=${PY3_PIP_VERSION} \
    shadow=${SHADOW_VERSION} \
    doas=${DOAS_VERSION} \
    curl=${CURL_VERSION} \
    tar=${TAR_VERSION} \
    unzip=${UNZIP_VERSION} \
    aws-cli==${AWS_CLI_VERSION} --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    ansible=${ANSIBLE_VERSION} --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community/ && \
    rm -rf /var/cache/apk/*

# Create a non-root user and set up doas
RUN adduser -D ciuser && \
    echo "permit nopass ciuser as root" > /etc/doas.d/ciuser.conf && \
    chmod 600 /etc/doas.d/ciuser.conf

# Install tenv from GitHub releases
RUN curl -L https://github.com/tofuutils/tenv/releases/download/${TENV_VERSION}/tenv_${TENV_VERSION}_amd64.apk -o tenv.apk && \
    apk add --no-cache --allow-untrusted tenv.apk && \
    rm tenv.apk

# Install versions of Terraform and OpenTofu
RUN tenv tofu install ${OPENTOFU_VERSION} && \
    tenv tf install ${TERRAFORM_VERSION} && \
    tenv tf use ${TERRAFORM_VERSION} && \
    tenv tofu use ${OPENTOFU_VERSION} && \
    mkdir -p /home/ciuser/.tenv && \
    cp -R /root/.tenv/* /home/ciuser/.tenv/ && \
    chown -R ciuser:ciuser /home/ciuser/.tenv

# Install Pulumi
RUN curl -L https://github.com/pulumi/pulumi/releases/download/${PULUMI_VERSION}/pulumi-${PULUMI_VERSION}-linux-x64.tar.gz -o pulumi.tar.gz && \
    tar -xzf pulumi.tar.gz -C /tmp && \
    rm pulumi.tar.gz && \
    mv /tmp/pulumi/* /usr/local/bin/ && \
    rmdir /tmp/pulumi

# Add pulumi to PATH
ENV PATH="/usr/local/bin:$PATH"

# Switch to ciuser
USER ciuser
WORKDIR /home/ciuser

# Set up environment for ciuser
RUN echo "export PATH='/home/ciuser/.tenv/bin:/usr/local/bin:$PATH'" >> ~/.profile && \
    echo "alias sudo='doas'" >> ~/.bashrc && \
    echo "source ~/.profile" >> ~/.bashrc

# Make sure the entrypoint loads the profile
ENTRYPOINT ["/bin/bash", "-l", "-c"]
