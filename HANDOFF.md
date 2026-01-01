# Agent Handoff: Add Lua 5.5 Support

## Goal
Add Lua 5.5 support to the lua-devcontainer project.

## Branch
`claude/add-lua-5.5-support-dfaO9`

## PR
https://github.com/jeduden/lua-devcontainer/pull/18

## Current Status
- **CI is failing** - "Test All Lua Versions" job fails
- Last commit: `3c412bf` - Fix Lua 5.5 build for Alpine/musl

## What's Been Done

### Files Modified
1. **Dockerfile** - Added multi-stage build to compile Lua 5.5 from source:
   - Build stage `lua55-builder` compiles Lua 5.5.0 and LuaRocks
   - Copies binaries to main image
   - Uses musl-compatible build flags

2. **vl** - Added `5.5` to `all_versions` array

3. **test/test_cli_tools.sh** - Added lua5.5 and luarocks-5.5 tests

4. **test/test_luacov.sh** - Added lua5.5 luacov tests

5. **test/test_package_isolation_matrix.sh** - Added 5.5 to version matrix

6. **README.md** - Updated version references to include 5.5

7. **src/lua-multiversion/devcontainer-template.json** - Added 5.5 option

8. **claude.md** - Added guidelines:
   - "Verify feasibility first" before implementing
   - "Always check CI results after pushing"

## Build Approach
Lua 5.5.0 was released Dec 22, 2025 but isn't in Alpine repos yet. Solution: compile from source in a multi-stage Docker build.

Current Dockerfile build stage:
```dockerfile
FROM alpine:3.21 AS lua55-builder

RUN apk add --no-cache gcc g++ musl-dev make readline-dev curl

WORKDIR /build
RUN curl -L -R -O https://www.lua.org/ftp/lua-5.5.0.tar.gz && \
    tar zxf lua-5.5.0.tar.gz && \
    cd lua-5.5.0 && \
    make -C src CC="gcc -std=gnu99" \
        SYSCFLAGS="-DLUA_USE_LINUX -DLUA_USE_READLINE" \
        SYSLIBS="-lreadline" \
        all && \
    make INSTALL_TOP=/usr/local install
```

## Build Flag History (Alpine/musl issues)
1. `PLAT=linux-musl` - Failed (not a valid platform)
2. `PLAT=linux MYLIBS="-ldl"` - Failed (musl doesn't have libdl)
3. `SYSCFLAGS="-DLUA_USE_LINUX -DLUA_USE_READLINE" SYSLIBS="-lreadline"` - Current attempt, still failing

## Known Issue: CI Detection
WebFetch has a 15-minute cache, making it unreliable for polling CI status. The `gh` CLI isn't authenticated in this environment.

**Recommendation**: Install GitHub MCP plugin for reliable CI checking:
```bash
claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=<token> -- npx -y @modelcontextprotocol/server-github
```

## Next Steps
1. Check actual CI failure logs (user needs to provide or install GitHub MCP)
2. Fix the Lua 5.5 build based on error
3. Push fix and verify CI passes
4. Get PR merged

## Key Files to Read
- `/home/user/lua-devcontainer/Dockerfile` - Build configuration
- `/home/user/lua-devcontainer/.github/workflows/test.yml` - CI workflow
- `/home/user/lua-devcontainer/claude.md` - Project guidelines
