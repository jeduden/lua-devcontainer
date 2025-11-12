#!/bin/bash
# Test package isolation across all Lua versions
# Shows which versions can see packages installed for each version

set -e

PACKAGE="luafilesystem"
TEST_SCRIPT="test/test_package_isolation.lua"

echo "========================================"
echo "LuaRocks Package Isolation Test Matrix"
echo "========================================"
echo ""

# Test matrix:
# Install for each version, then test all versions
for INSTALL_VERSION in 5.1 5.2 5.3 5.4 jit; do
    echo "----------------------------------------"
    echo "Installing $PACKAGE for version: $INSTALL_VERSION"
    echo "----------------------------------------"

    # Determine which luarocks to use
    if [ "$INSTALL_VERSION" = "jit" ]; then
        luarocks-5.1 install $PACKAGE > /dev/null 2>&1
    else
        luarocks-${INSTALL_VERSION} install $PACKAGE > /dev/null 2>&1
    fi

    echo "Testing which versions can see the package:"
    echo ""

    # Test all versions
    for TEST_VERSION in 5.1 5.2 5.3 5.4 jit; do
        # Determine expected behavior
        if [ "$INSTALL_VERSION" = "5.1" ] || [ "$INSTALL_VERSION" = "jit" ]; then
            # 5.1 and jit share packages
            if [ "$TEST_VERSION" = "5.1" ] || [ "$TEST_VERSION" = "jit" ]; then
                EXPECTED="true"
            else
                EXPECTED="false"
            fi
        else
            # All other versions are isolated
            if [ "$TEST_VERSION" = "$INSTALL_VERSION" ]; then
                EXPECTED="true"
            else
                EXPECTED="false"
            fi
        fi

        vl $TEST_VERSION lua $TEST_SCRIPT $TEST_VERSION $EXPECTED
    done

    echo ""
done

echo "========================================"
echo "All package isolation tests passed!"
echo "========================================"
