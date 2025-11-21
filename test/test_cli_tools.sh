#!/bin/bash
# Smoke Test: Verify all command line tools start successfully
# This is a fast startup test - does not test functionality, just that tools exist and run
# For functional tests, see test/run.lua and test/test_luacov.sh

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
        # Also show stderr for debugging
        "$@" 2>&1 | head -5 | sed 's/^/    /'
        ((FAILED++))
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
