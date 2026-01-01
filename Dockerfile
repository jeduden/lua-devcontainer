# Build stage for Lua 5.5
FROM alpine:3.21 AS lua55-builder

# Install build dependencies
RUN apk add --no-cache \
    gcc g++ musl-dev make readline-dev curl

# Download and build Lua 5.5
WORKDIR /build
RUN curl -L -R -O https://www.lua.org/ftp/lua-5.5.0.tar.gz && \
    tar zxf lua-5.5.0.tar.gz && \
    cd lua-5.5.0 && \
    make -C src CC="gcc -std=gnu99" \
        SYSCFLAGS="-DLUA_USE_LINUX -DLUA_USE_READLINE" \
        SYSLIBS="-lreadline" \
        all && \
    make INSTALL_TOP=/usr/local install

# Note: LuaRocks for Lua 5.5 will be installed in the main image
# This avoids path configuration issues with copying binaries between stages

# Main image
FROM mcr.microsoft.com/devcontainers/base:alpine

# Install all Lua versions, LuaRocks, and development tools in a single layer
RUN apk add --no-cache \
    # All Lua versions (5.1-5.4 from Alpine repos)
    lua5.1 lua5.1-dev lua5.1-libs \
    lua5.2 lua5.2-dev lua5.2-libs \
    lua5.3 lua5.3-dev lua5.3-libs \
    lua5.4 lua5.4-dev lua5.4-libs \
    luajit luajit-dev \
    # LuaRocks from Alpine repos (supports Lua 5.1-5.4)
    luarocks5.1 luarocks5.2 luarocks5.3 luarocks5.4 \
    # Development tools (runtime)
    bash git \
    # Build dependencies (needed for compiling rocks)
    gcc g++ musl-dev libc-dev make readline-dev \
    curl wget unzip tar gzip \
    cmake ca-certificates \
    pkgconf linux-headers

# Copy Lua 5.5 from builder stage (only the Lua binaries, headers, and library)
COPY --from=lua55-builder /usr/local/bin/lua /usr/local/bin/lua5.5
COPY --from=lua55-builder /usr/local/bin/luac /usr/local/bin/luac5.5
COPY --from=lua55-builder /usr/local/lib/liblua.a /usr/local/lib/liblua5.5.a
COPY --from=lua55-builder /usr/local/include/ /usr/local/include/lua5.5/

# Install LuaRocks 3.13.0 for Lua 5.5 (in main image to avoid path issues)
# LuaRocks 3.13.0+ is required for Lua 5.5 support
RUN curl -L -R -O https://luarocks.org/releases/luarocks-3.13.0.tar.gz && \
    tar zxf luarocks-3.13.0.tar.gz && \
    cd luarocks-3.13.0 && \
    ./configure --prefix=/usr/local \
        --with-lua-bin=/usr/local/bin \
        --with-lua-include=/usr/local/include/lua5.5 \
        --with-lua-interpreter=lua5.5 \
        --lua-version=5.5 \
        --versioned-rocks-dir && \
    make && \
    make install && \
    cd .. && rm -rf luarocks-3.13.0 luarocks-3.13.0.tar.gz && \
    mv /usr/local/bin/luarocks /usr/local/bin/luarocks-5.5 && \
    mv /usr/local/bin/luarocks-admin /usr/local/bin/luarocks-admin-5.5

# Create symlinks for luarocks commands
RUN ln -sf /usr/bin/luarocks-5.1 /usr/local/bin/luarocks-5.1 && \
    ln -sf /usr/bin/luarocks-5.2 /usr/local/bin/luarocks-5.2 && \
    ln -sf /usr/bin/luarocks-5.3 /usr/local/bin/luarocks-5.3 && \
    ln -sf /usr/bin/luarocks-5.4 /usr/local/bin/luarocks-5.4

# Install Lua Language Server from Alpine edge/community repository
# This provides a musl-compatible binary built by Alpine maintainers
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    lua-language-server

# Copy and install vl helper command
COPY vl /usr/local/bin/vl
RUN chmod +x /usr/local/bin/vl

# Create LuaRocks directories for user-installed packages
# Alpine's luarocks uses both /usr and /usr/local directories
RUN mkdir -p /usr/local/lib/luarocks/rocks-5.1 \
             /usr/local/lib/luarocks/rocks-5.2 \
             /usr/local/lib/luarocks/rocks-5.3 \
             /usr/local/lib/luarocks/rocks-5.4 \
             /usr/local/lib/luarocks/rocks-5.5 \
             /usr/local/share/lua/5.1 \
             /usr/local/share/lua/5.2 \
             /usr/local/share/lua/5.3 \
             /usr/local/share/lua/5.4 \
             /usr/local/share/lua/5.5 \
             /usr/local/lib/lua/5.1 \
             /usr/local/lib/lua/5.2 \
             /usr/local/lib/lua/5.3 \
             /usr/local/lib/lua/5.4 \
             /usr/local/lib/lua/5.5

# Install luacov for all Lua versions (as root, before switching user)
RUN luarocks-5.1 install luacov && \
    luarocks-5.2 install luacov && \
    luarocks-5.3 install luacov && \
    luarocks-5.4 install luacov && \
    luarocks-5.5 install luacov

# Set working directory and ensure vscode user owns it
WORKDIR /workspace
RUN chown vscode:vscode /workspace

# Ensure vscode home directory exists and has correct permissions
RUN mkdir -p /home/vscode && chown -R vscode:vscode /home/vscode

# Switch to vscode user
USER vscode

# Configure luarocks to install packages locally by default (to ~/.luarocks)
# This avoids needing write access to system directories
RUN luarocks-5.1 config local_by_default true && \
    luarocks-5.2 config local_by_default true && \
    luarocks-5.3 config local_by_default true && \
    luarocks-5.4 config local_by_default true && \
    luarocks-5.5 config local_by_default true

# Add luarocks local paths to shell profile so user-installed packages are found
RUN echo 'eval "$(luarocks-5.4 path)"' >> ~/.profile && \
    echo 'eval "$(luarocks-5.4 path)"' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
