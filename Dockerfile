FROM alpine:3.19

# Install all Lua versions and development tools in a single layer
RUN apk add --no-cache \
    # All Lua versions
    lua5.1 lua5.1-dev \
    lua5.2 lua5.2-dev \
    lua5.3 lua5.3-dev \
    lua5.4 lua5.4-dev \
    luajit luajit-dev \
    # Development tools (runtime)
    bash git \
    # Build dependencies (needed for LuaRocks and compiling rocks)
    gcc g++ musl-dev libc-dev make readline-dev \
    curl wget unzip tar gzip \
    cmake ca-certificates \
    pkgconf linux-headers

# Install LuaRocks for all Lua versions in a single layer
ENV LUAROCKS_VERSION=3.11.1
RUN set -ex && \
    wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    # Install for Lua 5.1
    ./configure \
        --lua-version=5.1 \
        --versioned-rocks-dir \
        --with-lua=/usr \
        --with-lua-bin=/usr/bin \
        --with-lua-include=/usr/include/lua5.1 \
        --with-lua-lib=/usr/lib \
        --lua-suffix=5.1 && \
    make && make install && make clean && \
    # Install for Lua 5.2
    ./configure \
        --lua-version=5.2 \
        --versioned-rocks-dir \
        --with-lua=/usr \
        --with-lua-bin=/usr/bin \
        --with-lua-include=/usr/include/lua5.2 \
        --with-lua-lib=/usr/lib \
        --lua-suffix=5.2 && \
    make && make install && make clean && \
    # Install for Lua 5.3
    ./configure \
        --lua-version=5.3 \
        --versioned-rocks-dir \
        --with-lua=/usr \
        --with-lua-bin=/usr/bin \
        --with-lua-include=/usr/include/lua5.3 \
        --with-lua-lib=/usr/lib \
        --lua-suffix=5.3 && \
    make && make install && make clean && \
    # Install for Lua 5.4
    ./configure \
        --lua-version=5.4 \
        --versioned-rocks-dir \
        --with-lua=/usr \
        --with-lua-bin=/usr/bin \
        --with-lua-include=/usr/include/lua5.4 \
        --with-lua-lib=/usr/lib \
        --lua-suffix=5.4 && \
    make && make install && \
    # Cleanup
    cd .. && rm -rf luarocks-${LUAROCKS_VERSION}*

# Copy and install test-all-lua helper script
COPY test-all-lua /usr/local/bin/test-all-lua
RUN chmod +x /usr/local/bin/test-all-lua

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
