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
    local cmd="$1"
    local args="$2"
    local description="$3"

    echo -n "Testing $description... "
    if $cmd $args > /dev/null 2>&1; then
        echo "✓ PASSED"
        ((PASSED++))
    else
        echo "✗ FAILED"
        ((FAILED++))
        return 1
    fi
}

echo "----------------------------------------"
echo "Testing Lua Interpreters"
echo "----------------------------------------"

test_command "lua5.1" "-e 'print(_VERSION)'" "lua5.1"
test_command "lua5.2" "-e 'print(_VERSION)'" "lua5.2"
test_command "lua5.3" "-e 'print(_VERSION)'" "lua5.3"
test_command "lua5.4" "-e 'print(_VERSION)'" "lua5.4"
test_command "luajit" "-e 'print(jit.version)'" "luajit"

echo ""
echo "----------------------------------------"
echo "Testing LuaRocks Package Managers"
echo "----------------------------------------"

test_command "luarocks-5.1" "--version" "luarocks-5.1"
test_command "luarocks-5.2" "--version" "luarocks-5.2"
test_command "luarocks-5.3" "--version" "luarocks-5.3"
test_command "luarocks-5.4" "--version" "luarocks-5.4"

echo ""
echo "----------------------------------------"
echo "Testing vl Helper Command"
echo "----------------------------------------"

test_command "vl" "all lua -e 'print(_VERSION)'" "vl all lua"
test_command "vl" "all luarocks --version" "vl all luarocks"
test_command "vl" "5.1,5.4,jit lua -e 'print(_VERSION)'" "vl with specific versions"

echo ""
echo "----------------------------------------"
echo "Testing luacov Installation"
echo "----------------------------------------"

# Test that luacov module can be required by each Lua version
test_command "lua5.1" "-e 'require(\"luacov\")'" "luacov for lua5.1"
test_command "lua5.2" "-e 'require(\"luacov\")'" "luacov for lua5.2"
test_command "lua5.3" "-e 'require(\"luacov\")'" "luacov for lua5.3"
test_command "lua5.4" "-e 'require(\"luacov\")'" "luacov for lua5.4"
test_command "luajit" "-e 'require(\"luacov\")'" "luacov for luajit"

# Test that luacov command line tool exists and runs
test_command "lua5.1" "-e 'require(\"luacov.runner\")'" "luacov.runner for lua5.1"
test_command "lua5.2" "-e 'require(\"luacov.runner\")'" "luacov.runner for lua5.2"
test_command "lua5.3" "-e 'require(\"luacov.runner\")'" "luacov.runner for lua5.3"
test_command "lua5.4" "-e 'require(\"luacov.runner\")'" "luacov.runner for lua5.4"
test_command "luajit" "-e 'require(\"luacov.runner\")'" "luacov.runner for luajit"

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
