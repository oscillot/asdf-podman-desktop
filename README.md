<div align="center">

# asdf-podman-desktop [![Build](https://github.com/oscillot/asdf-podman-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/oscillot/asdf-podman-desktop/actions/workflows/build.yml) [![Lint](https://github.com/oscillot/asdf-podman-desktop/actions/workflows/lint.yml/badge.svg)](https://github.com/oscillot/asdf-podman-desktop/actions/workflows/lint.yml)

[podman-desktop](https://github.com/oscillot/asdf-podman-desktop) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add podman-desktop
# or
asdf plugin add podman-desktop https://github.com/oscillot/asdf-podman-desktop.git
```

podman-desktop:

```shell
# Show all installable versions
asdf list-all podman-desktop

# Install specific version
asdf install podman-desktop latest

# Set a version globally (on your ~/.tool-versions file)
asdf global podman-desktop latest

# Now podman-desktop commands are available
true
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/oscillot/asdf-podman-desktop/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Oscillot](https://github.com/oscillot/)
