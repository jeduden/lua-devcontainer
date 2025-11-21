#!/bin/bash
# Test that all command line tools start successfully
# This ensures all Lua versions, LuaRocks, and installed packages work

set -e

echo "========================================"
echo "Command Line Tools Startup Test"
echo "========================================"
echo ""

# Track test results
PASSED=0
FAILED=0

# Helper function to test a command
test_command() {
    local description="$1"
    shift

    echo -n "Testing $description... "
    if "$@" > /dev/null 2>&1; then
        echo "✓ PASSED"
        ((PASSED++))
    else
        echo "✗ FAILED"
        echo "  Command: $@"
        ((FAILED++))
        return 1
    fi
}

echo "----------------------------------------"
echo "Testing Lua Interpreters"
echo "----------------------------------------"

test_command "lua5.1" lua5.1 -e 'print(_VERSION)'
test_command "lua5.2" lua5.2 -e 'print(_VERSION)'
test_command "lua5.3" lua5.3 -e 'print(_VERSION)'
test_command "lua5.4" lua5.4 -e 'print(_VERSION)'
test_command "luajit" luajit -e 'print(jit.version)'

echo ""
echo "----------------------------------------"
echo "Testing LuaRocks Package Managers"
echo "----------------------------------------"

test_command "luarocks-5.1" luarocks-5.1 --version
test_command "luarocks-5.2" luarocks-5.2 --version
test_command "luarocks-5.3" luarocks-5.3 --version
test_command "luarocks-5.4" luarocks-5.4 --version

echo ""
echo "----------------------------------------"
echo "Testing vl Helper Command"
echo "----------------------------------------"

test_command "vl all lua" vl all lua -e 'print(_VERSION)'
test_command "vl all luarocks" vl all luarocks --version
test_command "vl with specific versions" vl 5.1,5.4,jit lua -e 'print(_VERSION)'

echo ""
echo "----------------------------------------"
echo "Testing luacov Installation"
echo "----------------------------------------"

# Test that luacov module can be required by each Lua version
test_command "luacov for lua5.1" lua5.1 -e 'require("luacov")'
test_command "luacov for lua5.2" lua5.2 -e 'require("luacov")'
test_command "luacov for lua5.3" lua5.3 -e 'require("luacov")'
test_command "luacov for lua5.4" lua5.4 -e 'require("luacov")'
test_command "luacov for luajit" luajit -e 'require("luacov")'

# Test that luacov command line tool exists and runs
test_command "luacov.runner for lua5.1" lua5.1 -e 'require("luacov.runner")'
test_command "luacov.runner for lua5.2" lua5.2 -e 'require("luacov.runner")'
test_command "luacov.runner for lua5.3" lua5.3 -e 'require("luacov.runner")'
test_command "luacov.runner for lua5.4" lua5.4 -e 'require("luacov.runner")'
test_command "luacov.runner for luajit" luajit -e 'require("luacov.runner")'

echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ All command line tools working correctly!"
    exit 0
else
    echo "✗ Some tests failed!"
    exit 1
fi
