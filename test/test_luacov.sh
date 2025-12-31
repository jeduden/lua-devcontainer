#!/bin/bash
# Test that luacov is properly installed and accessible from all Lua versions
# This ensures code coverage analysis tools are available in the devcontainer

echo "========================================"
echo "Luacov Installation Test"
echo "========================================"
echo ""

# Track test results
PASSED=0
FAILED=0
SKIPPED=0

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

# Helper function to test a command only if the interpreter exists
test_command_if_exists() {
    local description="$1"
    local cmd="$2"
    shift 2

    if command -v "$cmd" >/dev/null 2>&1; then
        echo -n "Testing $description... "
        if "$cmd" "$@" > /dev/null 2>&1; then
            echo "✓ PASSED"
            ((PASSED++))
        else
            echo "✗ FAILED"
            echo "  Command: $cmd $@"
            "$cmd" "$@" 2>&1 | head -5 | sed 's/^/    /'
            ((FAILED++))
        fi
    else
        echo "Testing $description... ○ SKIPPED (interpreter not installed)"
        ((SKIPPED++))
    fi
}

echo "----------------------------------------"
echo "Testing luacov Module Availability"
echo "----------------------------------------"

# Test that luacov module can be required by each Lua version
test_command "luacov for lua5.1" lua5.1 -e 'require("luacov")'
test_command "luacov for lua5.2" lua5.2 -e 'require("luacov")'
test_command "luacov for lua5.3" lua5.3 -e 'require("luacov")'
test_command "luacov for lua5.4" lua5.4 -e 'require("luacov")'
test_command_if_exists "luacov for lua5.5" lua5.5 -e 'require("luacov")'
test_command "luacov for luajit" luajit -e 'require("luacov")'

echo ""
echo "----------------------------------------"
echo "Testing luacov.runner Module"
echo "----------------------------------------"

# Test that luacov.runner module exists and runs
test_command "luacov.runner for lua5.1" lua5.1 -e 'require("luacov.runner")'
test_command "luacov.runner for lua5.2" lua5.2 -e 'require("luacov.runner")'
test_command "luacov.runner for lua5.3" lua5.3 -e 'require("luacov.runner")'
test_command "luacov.runner for lua5.4" lua5.4 -e 'require("luacov.runner")'
test_command_if_exists "luacov.runner for lua5.5" lua5.5 -e 'require("luacov.runner")'
test_command "luacov.runner for luajit" luajit -e 'require("luacov.runner")'

echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Skipped: $SKIPPED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ All luacov tests passed!"
    exit 0
else
    echo "✗ Some luacov tests failed!"
    exit 1
fi
