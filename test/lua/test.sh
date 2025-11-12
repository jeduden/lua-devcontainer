#!/bin/bash
set -e

# Test all Lua versions are installed
echo "Testing Lua installations..."
for cmd in lua5.1 lua5.2 lua5.3 lua5.4 luajit; do
    if ! command -v $cmd &> /dev/null; then
        echo "ERROR: $cmd not found"
        exit 1
    fi
    echo "✓ $cmd is installed"
    $cmd -e 'print(_VERSION or "LuaJIT")'
done

# Test LuaRocks
echo "Testing LuaRocks..."
for cmd in luarocks-5.1 luarocks-5.2 luarocks-5.3 luarocks-5.4; do
    if ! command -v $cmd &> /dev/null; then
        echo "ERROR: $cmd not found"
        exit 1
    fi
    echo "✓ $cmd is installed"
done

# Test vl command
echo "Testing vl command..."
if ! command -v vl &> /dev/null; then
    echo "ERROR: vl command not found"
    exit 1
fi
echo "✓ vl command is installed"

# Test Lua Language Server
echo "Testing Lua Language Server..."
if ! command -v lua-language-server &> /dev/null; then
    echo "ERROR: lua-language-server not found"
    exit 1
fi
echo "✓ Lua Language Server is installed"
lua-language-server --version

# Test development tools
echo "Testing development tools..."
git --version
make --version

echo ""
echo "✅ All tests passed!"
