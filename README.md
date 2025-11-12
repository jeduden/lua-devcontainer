# Lua Multi-Version DevContainer

[![Build and Publish](https://github.com/jeduden/lua-devcontainer/actions/workflows/build.yml/badge.svg)](https://github.com/jeduden/lua-devcontainer/actions/workflows/build.yml)
[![Test](https://github.com/jeduden/lua-devcontainer/actions/workflows/test.yml/badge.svg)](https://github.com/jeduden/lua-devcontainer/actions/workflows/test.yml)

All Lua versions in a single, fast development container. No version switching needed - all versions work simultaneously.

## Features

- ✅ **All Lua Versions**: 5.1, 5.2, 5.3, 5.4, and LuaJIT
- ✅ **All LuaRocks**: Separate package manager for each Lua version
- ✅ **Direct Access**: Use `lua5.1`, `lua5.2`, `lua5.3`, `lua5.4`, or `luajit` directly
- ✅ **Test Helper**: `test-all-lua` command runs scripts with all versions
- ✅ **Development Tools**: gcc, make, git, cmake, and more pre-installed
- ✅ **Multi-Architecture**: Supports amd64 and arm64
- ✅ **Weekly Updates**: Automated security updates

## Quick Start

### Use with Docker
```bash
# Pull and run
docker run -it -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer:latest

# Run script with specific version
docker run -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer lua5.4 script.lua

# Test with all versions
docker run -v $PWD:/workspace ghcr.io/jeduden/lua-devcontainer test-all-lua script.lua
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
      - run: test-all-lua test/run.lua
```

### Test with Matrix Strategy
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/jeduden/lua-devcontainer:latest
    strategy:
      matrix:
        lua: [lua5.1, lua5.2, lua5.3, lua5.4, luajit]
    steps:
      - uses: actions/checkout@v4
      - run: ${{ matrix.lua }} test/run.lua
```

## Available Commands

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
| `test-all-lua` | Run script with all Lua versions |

## Examples

### Test Script with All Versions
```bash
# Using the helper
test-all-lua my_script.lua

# Or manually
for v in lua5.1 lua5.2 lua5.3 lua5.4 luajit; do
    echo "Testing with $v"
    $v my_script.lua
done
```

### Install Package for Specific Version
```bash
luarocks-5.4 install luacheck
luarocks-5.1 install luasocket
```

### Check Version
```bash
lua5.1 -e 'print(_VERSION)'  # Lua 5.1
lua5.4 -e 'print(_VERSION)'  # Lua 5.4
luajit -e 'print(jit.version)'  # LuaJIT 2.1.0-beta3
```

## For Latch Users

Add to your Latch project:

`.devcontainer/devcontainer.json`:
```json
{
  "name": "Latch Development",
  "image": "ghcr.io/jeduden/lua-devcontainer:latest",
  "postCreateCommand": "test-all-lua test/run.lua"
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
      - run: test-all-lua test/run.lua
```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please test with all Lua versions before submitting PRs.
