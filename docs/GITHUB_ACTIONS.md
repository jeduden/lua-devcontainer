# GitHub Actions Integration

This document describes how to integrate GitHub Actions security analysis into your development workflow using zizmor.

## Overview

[zizmor](https://docs.zizmor.sh/) is a static analysis tool for GitHub Actions that can find and fix many common security issues in typical GitHub Actions CI/CD setups. It helps ensure your workflows are secure and follow best practices.

## Integration Methods

### Official zizmor-action (Recommended)

The recommended way to integrate zizmor is using the official `zizmorcore/zizmor-action`. This GitHub Action provides automatic security analysis of your workflow files.

#### Basic Configuration

Create a workflow file in your repository (e.g., `.github/workflows/zizmor.yml`):

```yaml
name: GitHub Actions Security Analysis with zizmor 🌈

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["**"]

permissions: {}

jobs:
  zizmor:
    name: Run zizmor 🌈
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read # only needed for private repos
      actions: read # only needed for private repos
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      - name: Run zizmor 🌈
        uses: zizmorcore/zizmor-action@v1
```

### Configuration Options

#### Advanced Security Integration

The `advanced-security` option controls whether zizmor-action uses GitHub's Advanced Security functionality:

```yaml
- name: Run zizmor 🌈
  uses: zizmorcore/zizmor-action@v1
  with:
    advanced-security: true  # Upload results to GitHub Advanced Security (default)
```

If set to `false`, zizmor-action will not upload results to Advanced Security and will instead print them to the console.

#### Annotations

The `annotations` option controls whether zizmor-action emits GitHub annotations for findings:

```yaml
- name: Run zizmor 🌈
  uses: zizmorcore/zizmor-action@v1
  with:
    annotations: true  # Emit GitHub annotations for findings
```

**Note:** GitHub Actions has a limit of 10 annotations per step. If your zizmor run produces more than 10 findings, only the first 10 will be rendered as annotations.

## Best Practices

1. **Run on Multiple Events**: Configure zizmor to run on both push and pull request events to catch issues early.

2. **Minimal Permissions**: Use the principle of least privilege for workflow permissions. The example above shows the minimal permissions required.

3. **Disable Persist Credentials**: Always set `persist-credentials: false` when checking out code to avoid credential exposure.

4. **Regular Updates**: Keep the zizmor-action version up to date to benefit from the latest security checks.

## Resources

- [zizmor Documentation](https://docs.zizmor.sh/)
- [Integration Guide](https://docs.zizmor.sh/integrations/)
- [GitHub Marketplace - zizmor-action](https://github.com/marketplace/actions/zizmor-action)
- [zizmor GitHub Repository](https://github.com/zizmorcore/zizmor)

## What zizmor Detects

zizmor performs static analysis to identify common security vulnerabilities in GitHub Actions workflows, including:

- Insecure use of secrets and credentials
- Script injection vulnerabilities
- Excessive permissions
- Outdated or vulnerable actions
- Workflow security misconfigurations
- And many other common security issues

For a complete list of security checks, refer to the [official documentation](https://docs.zizmor.sh/).
