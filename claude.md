# Claude Development Guide

This document provides guidelines for Claude (AI assistant) when working on this project.

## Testing Requirements

### When to Add Tests

**ALWAYS add tests when:**

1. **Adding new command-line tools** - Any new binary, script, or command must have a startup test
2. **Installing new packages** - LuaRocks packages must be tested for availability across all Lua versions
3. **Modifying the Dockerfile** - Changes that affect the runtime environment need corresponding tests
4. **Adding new Lua versions** - Each version must be tested in all test suites
5. **Changing build dependencies** - Verify that compilation tools still work
6. **Modifying the `vl` helper** - Test with various version combinations

### Existing Test Suite

The project has the following tests in the `test/` directory, organized by test type:

#### Smoke Tests (Fast - Fail Fast)

##### 1. `test/test_cli_tools.sh`
**Purpose**: Verifies all command-line tools start successfully (smoke test only)

Tests:
- All Lua interpreters (5.1, 5.2, 5.3, 5.4, LuaJIT) start
- All LuaRocks package managers (luarocks-5.1 through luarocks-5.4) start

**When to update**: When adding new Lua versions or command-line tools

**Note**: This is a smoke test only - it verifies tools exist and start, but doesn't test functionality

#### Functional Tests (Medium)

##### 2. `test/run.lua`
**Purpose**: Tests basic Lua functionality across all versions

Tests:
- Lua version detection
- Basic arithmetic, strings, tables, functions
- LuaJIT detection

**When to update**: When adding Lua-specific features or libraries

**Run via**: `vl all lua test/run.lua` (tests all versions automatically)

##### 3. `test/test_luacov.sh`
**Purpose**: Verifies luacov code coverage tool is installed for all Lua versions

Tests:
- `luacov` module can be required from all Lua versions
- `luacov.runner` module is available for all versions

**When to update**: When adding new Lua versions or coverage-related packages

#### Integration Tests (Comprehensive)

##### 4. `test/test_package_isolation_matrix.sh`
**Purpose**: Verifies package isolation between Lua versions

Tests:
- Packages installed for one version aren't visible to others (except 5.1/LuaJIT)
- Lua 5.1 and LuaJIT share packages correctly
- Full matrix testing across all version combinations

**When to update**: When changing LuaRocks configuration or package installation logic

### Running Tests Locally

Tests cannot be run directly in this environment (no Docker available), but you can:

1. **Review test scripts** before committing
2. **Verify test syntax** using bash -n:
   ```bash
   bash -n test/test_cli_tools.sh
   ```
3. **Check for obvious errors** in test logic

### Running Tests in CI

All tests run automatically in GitHub Actions:

1. `.github/workflows/test.yml` - Runs on every pull request
2. Tests run in order (organized by test type):
   - **Smoke Test**: CLI tools startup (fails fast if tools don't exist)
   - **Functional Test**: Lua features (`vl all lua test/run.lua`)
   - **Functional Test**: Luacov coverage tools
   - **Integration Test**: Package isolation matrix

This ordering ensures fast feedback - smoke tests fail immediately if basic tools are broken.

### Test Structure Guidelines

When writing new tests:

1. **Use clear output formatting**
   ```bash
   echo "========================================"
   echo "Test Name"
   echo "========================================"
   ```

2. **Test one thing at a time**
   - Each test should verify a specific behavior
   - Use descriptive test names

3. **Provide failure context**
   ```bash
   if ! command; then
       echo "✗ FAILED"
       echo "  Command: $command"
       echo "  Expected: $expected"
       return 1
   fi
   ```

4. **Track pass/fail counts**
   ```bash
   PASSED=0
   FAILED=0
   # ... tests ...
   echo "Passed: $PASSED"
   echo "Failed: $FAILED"
   ```

5. **Exit with proper codes**
   - Exit 0 on success
   - Exit 1 on any failure

### Maintaining Tests

**Regular maintenance tasks:**

1. **After Dockerfile changes**
   - Review all tests in `test/`
   - Add tests for new functionality
   - Update tests for removed functionality

2. **When tests fail in CI**
   - Check the CI logs for the exact failure
   - Reproduce locally if possible (requires Docker)
   - Fix the root cause, not just the test

3. **Keep tests synchronized**
   - If you modify a test script, check if other tests need updates
   - Keep test names consistent across files
   - Update this documentation when test structure changes

### Test Coverage Checklist

Before committing changes, verify:

- [ ] All command-line tools have startup tests
- [ ] All installed packages are tested for availability
- [ ] All Lua versions are tested (5.1, 5.2, 5.3, 5.4, LuaJIT)
- [ ] The `vl` helper is tested with relevant version combinations
- [ ] Package isolation is maintained (except 5.1/LuaJIT)
- [ ] Tests provide clear pass/fail output
- [ ] Tests exit with correct status codes

## Common Issues

### Quoting in Test Scripts

**Problem**: Shell quoting can break test functions

**Bad**:
```bash
test_command "lua5.1" "-e 'print(_VERSION)'" "description"
# The quotes don't get parsed correctly when expanded
```

**Good**:
```bash
test_command "description" lua5.1 -e 'print(_VERSION)'
# Use "$@" to properly handle all arguments
```

### Test Ordering

**Problem**: Tests that depend on each other can cause false failures

**Solution**:
- Make each test independent
- Clean up after tests (remove installed packages, etc.)
- Run setup at the start of each test if needed

### Docker Build Context

**Problem**: Tests need access to the `test/` directory

**Solution**:
```yaml
docker run --rm -v $PWD/test:/workspace/test image-name bash test/script.sh
```

## Questions?

If you're unsure whether to add a test:
- **Default to YES** - More tests are better than fewer
- Ask the user if the change is significant
- Check existing tests for similar patterns
