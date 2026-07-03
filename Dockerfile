FROM golang:1.25-bookworm

# 1. generate locales
RUN apt-get update && apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 2. install system tools, python3, and network stack
RUN apt-get update && apt-get install -y \
    curl wget git make jq nano htop tree unzip zip \
    python3 python3-pip python3-venv \
    iputils-ping net-tools dnsutils iproute2 procps \
    apt-transport-https ca-certificates gnupg lsb-release \
    && apt-get clean

# 3. install node.js 24 lts
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs

# 4. install docker cli & compose plugin (dood setup)
RUN mkdir -m 0755 -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin \
    && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# 5. copy initialization scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /workspace

CMD ["/usr/local/bin/entrypoint.sh"]
