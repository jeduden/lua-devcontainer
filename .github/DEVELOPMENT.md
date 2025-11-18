# Development Guide

## Core Principles

1. **All changes must work across all Lua versions** (5.1, 5.2, 5.3, 5.4, LuaJIT)
2. **Container size must stay minimal** (<350MB target)
3. **Test with `vl all` before merging**
4. **Document version-specific behavior in README**

## Development Process

### 1. Before Making Changes

- Review multi-version requirements in README
- Check existing tests in `test/`
- Understand package isolation (5.1/LuaJIT share packages, others isolated)

### 2. Making Changes

#### Adding a Lua Version
- Update `Dockerfile` with new version installation
- Update `vl` script to include new version in mappings
- Add tests for version-specific behavior
- Update README version tables and examples

#### Updating Dependencies
- Keep Alpine packages minimal
- Test container size after changes: `docker images ghcr.io/jeduden/lua-devcontainer`
- Document any new dependencies in README

#### Modifying `vl` Script
- Maintain backward compatibility
- Test with all version combinations: `vl all`, `vl 5.1,5.4`, `vl jit`
- Update examples if command syntax changes

### 3. Testing Locally

```bash
# Build container
docker build -t lua-devcontainer-test .

# Run test suite with all versions
docker run lua-devcontainer-test vl all lua test/run.lua

# Test specific versions
docker run lua-devcontainer-test vl 5.3,5.4,jit lua test/run.lua

# Verify LuaRocks isolation
docker run -it lua-devcontainer-test ./test/test_package_isolation_matrix.sh

# Check container size
docker images lua-devcontainer-test
```

### 4. Validation Checklist

Before submitting PR:

- [ ] All Lua versions tested: `vl all lua test/run.lua` passes
- [ ] Individual versions work: `vl 5.1`, `vl 5.2`, `vl 5.3`, `vl 5.4`, `vl jit`
- [ ] LuaRocks commands work: `vl all luarocks --version`
- [ ] Package isolation maintained (5.1/LuaJIT exception documented)
- [ ] Container builds successfully
- [ ] Container size acceptable (<350MB)
- [ ] README updated with changes
- [ ] Version-specific notes added if applicable

### 5. CI/CD Validation

GitHub Actions will automatically:
- Build for amd64 and arm64
- Run test suite across all versions
- Validate container size
- Check for security issues (zizmor)

## Common Tasks

### Test a Single Lua Version
```bash
docker run lua-devcontainer-test lua5.4 test/run.lua
```

### Debug Container Interactively
```bash
docker run -it lua-devcontainer-test sh
# Then run commands manually
```

### Check Which Packages Are Installed
```bash
# For a specific version
docker run lua-devcontainer-test luarocks-5.4 list

# For all versions
docker run lua-devcontainer-test sh -c 'for v in 5.1 5.2 5.3 5.4; do echo "=== Lua $v ==="; luarocks-$v list; done'
```

### Verify Version Outputs
```bash
docker run lua-devcontainer-test vl all lua -e 'print(_VERSION)'
docker run lua-devcontainer-test luajit -e 'print(jit.version)'
```

## Architecture Decisions

### Why Alpine?
- Minimal base image (~5MB)
- Efficient package manager (apk)
- Security-focused with regular updates
- Good balance of size vs. functionality

### Why Separate LuaRocks per Version?
- Version isolation prevents conflicts
- Different Lua versions may need different compiled modules
- Exception: 5.1 and LuaJIT share packages (both use Lua 5.1 API)

### Why `vl` Command?
- Simplifies multi-version testing
- Common interface across all versions
- Reduces boilerplate in CI/CD and documentation

### Why All Versions?
- Users need to test compatibility across versions
- Different projects target different Lua versions
- Avoid needing multiple containers

## Troubleshooting

### Container Size Growing
1. Check for cached apk files: ensure `--no-cache` used
2. Review layer count: combine RUN commands where possible
3. Verify cleanup commands run in same layer as installations
4. Check for unnecessary development dependencies

### Test Failures Across Versions
1. Identify version-specific syntax (e.g., `goto` in 5.2+)
2. Check for deprecated features (e.g., `setfenv` removed in 5.2)
3. Verify package isolation (common issue: assuming shared packages)
4. Test LuaJIT separately (different behavior from 5.1)

### LuaRocks Installation Issues
1. Ensure development headers installed (`lua5.x-dev` packages)
2. Check compiler availability (`gcc`, `make`)
3. Verify correct LuaRocks version for Lua version
4. Remember: installing for one version doesn't install for others

## Getting Help

- Check existing issues: https://github.com/jeduden/lua-devcontainer/issues
- Review test examples: `test/` directory
- Read Lua version docs: https://www.lua.org/manual/
- LuaRocks guide: https://luarocks.org/

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following these guidelines
4. Test thoroughly with `vl all`
5. Submit PR with clear description
6. Ensure CI passes

Thank you for contributing to lua-devcontainer!
