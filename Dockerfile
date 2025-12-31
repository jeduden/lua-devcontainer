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

# Try to install Lua 5.5 if available (not yet released as of 2025)
# This will succeed once Alpine packages Lua 5.5
RUN apk add --no-cache lua5.5 lua5.5-dev lua5.5-libs luarocks5.5 2>/dev/null || true

# Create symlinks for luarocks commands without version suffix
RUN ln -sf /usr/bin/luarocks-5.1 /usr/local/bin/luarocks-5.1 && \
    ln -sf /usr/bin/luarocks-5.2 /usr/local/bin/luarocks-5.2 && \
    ln -sf /usr/bin/luarocks-5.3 /usr/local/bin/luarocks-5.3 && \
    ln -sf /usr/bin/luarocks-5.4 /usr/local/bin/luarocks-5.4 && \
    ([ -f /usr/bin/luarocks-5.5 ] && ln -sf /usr/bin/luarocks-5.5 /usr/local/bin/luarocks-5.5 || true)

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
    (command -v luarocks-5.5 >/dev/null 2>&1 && luarocks-5.5 install luacov || true)

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
    (command -v luarocks-5.5 >/dev/null 2>&1 && luarocks-5.5 config local_by_default true || true)

# Add luarocks local paths to shell profile so user-installed packages are found
RUN echo 'eval "$(luarocks-5.4 path)"' >> ~/.profile && \
    echo 'eval "$(luarocks-5.4 path)"' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
