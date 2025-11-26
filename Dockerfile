FROM mcr.microsoft.com/devcontainers/base:alpine

# Install all Lua versions, LuaRocks, and development tools in a single layer
RUN apk add --no-cache \
    # All Lua versions
    lua5.1 lua5.1-dev lua5.1-libs \
    lua5.2 lua5.2-dev lua5.2-libs \
    lua5.3 lua5.3-dev lua5.3-libs \
    lua5.4 lua5.4-dev lua5.4-libs \
    luajit luajit-dev \
    # LuaRocks from Alpine repos (supports all Lua versions)
    luarocks5.1 luarocks5.2 luarocks5.3 luarocks5.4 \
    # Development tools (runtime)
    bash git \
    # Build dependencies (needed for compiling rocks)
    gcc g++ musl-dev libc-dev make readline-dev \
    curl wget unzip tar gzip \
    cmake ca-certificates \
    pkgconf linux-headers

# Create symlinks for luarocks commands without version suffix
RUN ln -sf /usr/bin/luarocks-5.1 /usr/local/bin/luarocks-5.1 && \
    ln -sf /usr/bin/luarocks-5.2 /usr/local/bin/luarocks-5.2 && \
    ln -sf /usr/bin/luarocks-5.3 /usr/local/bin/luarocks-5.3 && \
    ln -sf /usr/bin/luarocks-5.4 /usr/local/bin/luarocks-5.4

# Install Lua Language Server for sumneko.lua extension
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH_NAME="x64"; \
    elif [ "$ARCH" = "aarch64" ]; then ARCH_NAME="arm64"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    curl -L https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-linux-$ARCH_NAME.tar.gz -o /tmp/lua-ls.tar.gz && \
    mkdir -p /opt/lua-language-server && \
    tar -xzf /tmp/lua-ls.tar.gz -C /opt/lua-language-server && \
    ln -sf /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server && \
    rm /tmp/lua-ls.tar.gz

# Copy and install vl helper command
COPY vl /usr/local/bin/vl
RUN chmod +x /usr/local/bin/vl

# Create LuaRocks directories for user-installed packages
# Alpine's luarocks uses both /usr and /usr/local directories
RUN mkdir -p /usr/local/lib/luarocks/rocks-5.1 \
             /usr/local/lib/luarocks/rocks-5.2 \
             /usr/local/lib/luarocks/rocks-5.3 \
             /usr/local/lib/luarocks/rocks-5.4 \
             /usr/local/share/lua/5.1 \
             /usr/local/share/lua/5.2 \
             /usr/local/share/lua/5.3 \
             /usr/local/share/lua/5.4 \
             /usr/local/lib/lua/5.1 \
             /usr/local/lib/lua/5.2 \
             /usr/local/lib/lua/5.3 \
             /usr/local/lib/lua/5.4

# Install luacov for all Lua versions (as root, before switching user)
RUN luarocks-5.1 install luacov && \
    luarocks-5.2 install luacov && \
    luarocks-5.3 install luacov && \
    luarocks-5.4 install luacov

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
    luarocks-5.4 config local_by_default true

# Add luarocks local paths to shell profile so user-installed packages are found
RUN echo 'eval "$(luarocks-5.4 path)"' >> ~/.profile && \
    echo 'eval "$(luarocks-5.4 path)"' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
