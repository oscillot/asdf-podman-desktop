# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

# TODO: update this
asdf plugin test podman-desktop https://github.com/oscillot/asdf-podman-desktop.git "/bin/true"
```

Tests are automatically run in GitHub Actions on push and PR.
