# Lua Multi-Version DevContainer

[![Build and Publish](https://github.com/jeduden/lua-devcontainer/actions/workflows/build.yml/badge.svg)](https://github.com/jeduden/lua-devcontainer/actions/workflows/build.yml)
[![Test](https://github.com/jeduden/lua-devcontainer/actions/workflows/test.yml/badge.svg)](https://github.com/jeduden/lua-devcontainer/actions/workflows/test.yml)

All Lua versions in a single, fast development container. No version switching needed - all versions work simultaneously.

## Features

- ✅ **All Lua Versions**: 5.1, 5.2, 5.3, 5.4, and LuaJIT
- ✅ **All LuaRocks**: Separate package manager for each Lua version
- ✅ **Unified Command**: `vl` command to run lua/luarocks with any version combination
- ✅ **Direct Access**: Use `lua5.1`, `lua5.2`, `lua5.3`, `lua5.4`, or `luajit` directly
- ✅ **Development Tools**: gcc, make, git, cmake, and more pre-installed
- ✅ **Small & Fast**: Alpine-based for minimal size (~200MB, [exact size in Build workflow](https://github.com/jeduden/lua-devcontainer/actions/workflows/build.yml))
- ✅ **Multi-Architecture**: Supports amd64 and arm64
- ✅ **Weekly Updates**: Automated security updates

## Quick Start

### Use with Docker
```bash
# Pull and run
docker run -it -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer:latest

# Test script with all Lua versions
docker run -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer vl all lua script.lua

# Test with specific versions only
docker run -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer vl 5.3,5.4 lua script.lua

# Install LuaRocks package for all versions
docker run -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer vl all luarocks install luacheck

# Or use specific version directly
docker run -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer lua5.4 script.lua
```

### Use as DevContainer

Create `.devcontainer/devcontainer.json`:
```json
{
  "image": "ghcr.io/jeduden/lua-devcontainer:latest"
}
```

### Use in GitHub Actions
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/jeduden/lua-devcontainer:latest
    steps:
      - uses: actions/checkout@v4
      - name: Test with all Lua versions
        run: vl all lua test/run.lua

      - name: Verify LuaRocks
        run: vl all luarocks --version
```

### Test Specific Versions with Matrix
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/jeduden/lua-devcontainer:latest
    strategy:
      matrix:
        lua: ['5.1', '5.2', '5.3', '5.4', 'jit']
    steps:
      - uses: actions/checkout@v4
      - run: vl ${{ matrix.lua }} lua test/run.lua
```

## Available Commands

### Main Commands

| Command | Description |
|---------|-------------|
| `vl <versions> lua [args...]` | Run lua with specified versions (e.g., `vl all lua script.lua`) |
| `vl <versions> luarocks [args...]` | Run luarocks with specified versions (e.g., `vl 5.3,5.4 luarocks install pkg`) |

**Version syntax**: `all`, `5.1`, `5.2`, `5.3`, `5.4`, `jit`, or comma-separated (e.g., `5.1,5.4,jit`)

**Important Notes**:
- LuaJIT uses the Lua 5.1 API, so `vl jit luarocks` will use `luarocks-5.1`
- Each Lua version has isolated packages - installing for one version doesn't make it available to others
- Exception: Lua 5.1 and LuaJIT share the same package directory (both use `luarocks-5.1`)

### Direct Access Commands

| Command | Description |
|---------|-------------|
| `lua5.1` | Lua 5.1 interpreter |
| `lua5.2` | Lua 5.2 interpreter |
| `lua5.3` | Lua 5.3 interpreter |
| `lua5.4` | Lua 5.4 interpreter |
| `luajit` | LuaJIT 2.1 interpreter |
| `luarocks-5.1` | LuaRocks for Lua 5.1 |
| `luarocks-5.2` | LuaRocks for Lua 5.2 |
| `luarocks-5.3` | LuaRocks for Lua 5.3 |
| `luarocks-5.4` | LuaRocks for Lua 5.4 |

## Examples

### Test Script with All Versions
```bash
# Using vl
vl all lua my_script.lua

# Or manually with direct commands
for v in lua5.1 lua5.2 lua5.3 lua5.4 luajit; do
    echo "Testing with $v"
    $v my_script.lua
done
```

### Test with Specific Versions
```bash
# Test with only Lua 5.3 and 5.4
vl 5.3,5.4 lua my_script.lua

# Test with Lua 5.4 and LuaJIT only
vl 5.4,jit lua my_script.lua
```

### Install LuaRocks Packages
```bash
# Install for all Lua versions (including LuaJIT via luarocks-5.1)
vl all luarocks install luacheck

# Install for specific versions only
vl 5.3,5.4 luarocks install luasocket

# Install for LuaJIT (uses luarocks-5.1)
vl jit luarocks install luasocket

# Or install for a single version directly
luarocks-5.4 install luacheck
luarocks-5.1 install luasocket  # Works for both Lua 5.1 and LuaJIT
```

### Understanding Package Isolation

**Important**: Each Lua version has its own isolated package directory:
- Installing for Lua 5.4 does NOT make the package available to Lua 5.3
- Installing for Lua 5.2 does NOT make the package available to Lua 5.3
- **Exception**: Lua 5.1 and LuaJIT share packages (both use `luarocks-5.1`)

```bash
# Install for Lua 5.4 only - NOT available to other versions
luarocks-5.4 install luasocket
lua5.4 -e "require('socket')"  # ✓ Works
lua5.3 -e "require('socket')"  # ✗ Error: module not found

# Install for Lua 5.1 - available to BOTH Lua 5.1 AND LuaJIT
luarocks-5.1 install luasocket
lua5.1 -e "require('socket')"   # ✓ Works
luajit -e "require('socket')"    # ✓ Works (shared with 5.1)
lua5.4 -e "require('socket')"    # ✗ Error: module not found

# To make available everywhere, install for all versions
vl all luarocks install luasocket
# This installs separately for: 5.1, 5.2, 5.3, 5.4 (and 5.1 covers LuaJIT)
```

### Check Versions
```bash
# Check all Lua versions
vl all lua -e 'print(_VERSION)'

# Check specific version
lua5.1 -e 'print(_VERSION)'  # Lua 5.1
luajit -e 'print(jit.version)'  # LuaJIT 2.1.0-beta3
```

## For Latch Users

Add to your Latch project:

`.devcontainer/devcontainer.json`:
```json
{
  "name": "Latch Development",
  "image": "ghcr.io/jeduden/lua-devcontainer:latest",
  "postCreateCommand": "vl all lua test/run.lua"
}
```

`.github/workflows/test.yml`:
```yaml
name: Test Latch
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/jeduden/lua-devcontainer:latest
    steps:
      - uses: actions/checkout@v4
      - name: Test all Lua versions
        run: vl all lua test/run.lua
      - name: Verify LuaRocks
        run: vl all luarocks --version
```

## Container Architecture

- **Base Image**: Alpine Linux 3.19 (~5MB base)
- **Total Size**: ~200MB ([exact size in Build workflow](https://github.com/jeduden/lua-devcontainer/actions/workflows/build.yml))
- **Layers**: Optimized to minimize layer count
- **Package Manager**: apk (Alpine), no cache retention
- **Build Strategy**: Single-layer installs for maximum efficiency

The container is optimized for size without sacrificing functionality. All Lua versions and build tools are included while keeping the footprint minimal.

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please test with all Lua versions before submitting PRs.
