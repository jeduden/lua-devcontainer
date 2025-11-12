#!/usr/bin/env lua
-- Simple test script to verify Lua installation

print("========================================")
print("Lua Installation Test")
print("========================================")
print("")

-- Test 1: Print Lua version
print("✓ Lua version: " .. _VERSION)

-- Test 2: Basic arithmetic
local result = 2 + 2
assert(result == 4, "Arithmetic test failed")
print("✓ Basic arithmetic: 2 + 2 = " .. result)

-- Test 3: String operations
local str = "Hello, Lua!"
assert(#str == 11, "String length test failed")
print("✓ String operations: '" .. str .. "' has " .. #str .. " characters")

-- Test 4: Table operations
local tbl = {1, 2, 3, 4, 5}
local sum = 0
for _, v in ipairs(tbl) do
    sum = sum + v
end
assert(sum == 15, "Table iteration test failed")
print("✓ Table operations: Sum of {1,2,3,4,5} = " .. sum)

-- Test 5: Function definition
local function factorial(n)
    if n <= 1 then
        return 1
    else
        return n * factorial(n - 1)
    end
end
local fact5 = factorial(5)
assert(fact5 == 120, "Function test failed")
print("✓ Function definition: 5! = " .. fact5)

-- Test 6: Check if we're running under LuaJIT
if jit then
    print("✓ Running under LuaJIT: " .. jit.version)
else
    print("✓ Running under standard Lua")
end

print("")
print("========================================")
print("All tests passed!")
print("========================================")
