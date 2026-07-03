FROM golang:1.25-bookworm

# 1. generate locales
RUN apt-get update && apt-get install -y locales supervisor && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 2. install system tools, python3, and network stack
RUN apt-get update && apt-get install -y \
    curl wget git make jq nano htop tree unzip zip \
    python3 python3-pip python3-venv \
    iputils-ping net-tools dnsutils iproute2 procps \
    apt-transport-https ca-certificates gnupg lsb-release zsh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. install node.js 24 lts
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. install docker cli & compose plugin (dood setup)
RUN npm install -g opencode-ai || npm install -g @opencode/cli || true
RUN curl -fsSL https://openclaw.ai/install.sh | bash

# 5. ZSH settings
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting
COPY configs/zshrc_template /root/.zshrc
RUN chsh -s /bin/zsh root

# 6. Supervisor settings
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /workspace

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
