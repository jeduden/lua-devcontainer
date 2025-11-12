#!/usr/bin/env lua
-- Test script to verify LuaRocks package isolation between Lua versions

local test_package = "luafilesystem"
local version = arg[1]
local should_exist = arg[2] == "true"

if not version then
    print("Usage: test_package_isolation.lua <version> <should_exist>")
    print("Example: test_package_isolation.lua 5.4 true")
    os.exit(1)
end

-- Try to require the package
local ok, result = pcall(require, "lfs")

if should_exist then
    if ok then
        print(string.format("✓ PASS: %s is available in Lua %s (expected)", test_package, version))
        os.exit(0)
    else
        print(string.format("✗ FAIL: %s should be available in Lua %s but got error: %s", test_package, version, result))
        os.exit(1)
    end
else
    if not ok then
        print(string.format("✓ PASS: %s is NOT available in Lua %s (expected, isolated)", test_package, version))
        os.exit(0)
    else
        print(string.format("✗ FAIL: %s should NOT be available in Lua %s (package isolation violated)", test_package, version))
        os.exit(1)
    end
end
