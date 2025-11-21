# Claude Development Guide

Guidelines for Claude (AI assistant) when working on this project.

## Testing Requirements

### When to Add Tests

**ALWAYS add tests when:**
1. Adding new command-line tools
2. Installing new LuaRocks packages
3. Modifying the Dockerfile
4. Adding new Lua versions
5. Changing the `vl` helper

### Test Structure

Tests are organized in `test/` directory:

**Smoke Tests** (fast, fail-fast)
- `test/test_cli_tools.sh` - CLI tools start successfully

**Functional Tests** (medium)
- `test/run.lua` - Lua functionality works
- `test/test_luacov.sh` - Luacov installed for all versions

**Integration Tests** (comprehensive)
- `test/test_package_isolation_matrix.sh` - Package isolation between versions

### Key Rules

1. **Update all relevant tests** when adding new Lua versions
2. **Test all versions** (5.1, 5.2, 5.3, 5.4, LuaJIT)
3. **Add startup test** for any new CLI tool
4. **Verify package availability** for all versions when installing packages
5. **Check CI logs** when tests fail - fix root cause, not just tests

### Test Guidelines

- Use `"$@"` for proper argument handling in bash functions
- Make tests independent (don't depend on other tests)
- Provide clear pass/fail output with counts
- Exit 0 on success, 1 on failure
