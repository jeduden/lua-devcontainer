FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    cmake \
    git \
    curl \
    wget \
    unzip \
    libreadline-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install all Lua versions from Ubuntu packages
RUN apt-get update && apt-get install -y \
    lua5.1 liblua5.1-dev \
    lua5.2 liblua5.2-dev \
    lua5.3 liblua5.3-dev \
    lua5.4 liblua5.4-dev \
    luajit libluajit-5.1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install LuaRocks for each Lua version
# LuaRocks version
ENV LUAROCKS_VERSION=3.11.1

# Install LuaRocks for Lua 5.1
RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure --lua-version=5.1 --versioned-rocks-dir && \
    make && make install && \
    cd .. && rm -rf luarocks-${LUAROCKS_VERSION}*

# Install LuaRocks for Lua 5.2
RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure --lua-version=5.2 --versioned-rocks-dir && \
    make && make install && \
    cd .. && rm -rf luarocks-${LUAROCKS_VERSION}*

# Install LuaRocks for Lua 5.3
RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure --lua-version=5.3 --versioned-rocks-dir && \
    make && make install && \
    cd .. && rm -rf luarocks-${LUAROCKS_VERSION}*

# Install LuaRocks for Lua 5.4
RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure --lua-version=5.4 --versioned-rocks-dir && \
    make && make install && \
    cd .. && rm -rf luarocks-${LUAROCKS_VERSION}*

# Create test-all-lua helper script
COPY test-all-lua /usr/local/bin/test-all-lua
RUN chmod +x /usr/local/bin/test-all-lua

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
