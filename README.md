# Vamposer

Dependency manager for Vala projects inspired by Composer/Go modules and integrated with Meson subprojects.


![GitHub Release](https://img.shields.io/github/v/release/ValaFoundation/vamposer?style=for-the-badge)
![GitHub Release Date](https://img.shields.io/github/release-date/ValaFoundation/vamposer?style=for-the-badge)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/ValaFoundation/vamposer/total?style=for-the-badge)
![GitHub License](https://img.shields.io/github/license/ValaFoundation/vamposer?style=for-the-badge)


![GitHub top language](https://img.shields.io/github/languages/top/ValaFoundation/vamposer?style=for-the-badge)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ValaFoundation/vamposer/ci.yml?style=for-the-badge)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/ValaFoundation/vamposer/latest?style=for-the-badge)


![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/ValaFoundation/vamposer?style=for-the-badge)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues-closed/ValaFoundation/vamposer?style=for-the-badge)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues-pr/ValaFoundation/vamposer?style=for-the-badge)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues-pr-closed/ValaFoundation/vamposer?style=for-the-badge)



## ✨ What it does

`vamposer install` currently performs:

- loading `vamposer.json`
- checking `system_dependencies` via `pkg-config --exists`
- attempting best-effort installation of missing `system_dependencies` via detected system package manager
	- includes distro package-name mapping for common pkg-config names (e.g. `gtk4`, `libadwaita-1`, `gee-0.8`)
	- unresolved system deps are reported as warning and install continues with VCS dependencies
- resolving Git-like dependency IDs to repository URLs
- cloning dependencies into `subprojects/<project-name>`
- generating Meson helper files:
	- `vamposer/meson.build`
	- `vamposer.build`
	- `subprojects/<project-name>.wrap`
	- `subprojects/vamposer.build`
	- `subprojects/vamposer/meson.build`

Default install includes only `dependencies`. Use `vamposer install --dev` to include both `dependencies` and `dependencies-dev`.

## 🚀 Run

### 🐧 Linux

Manual install (curl + chmod):

```bash
curl -fL -o vamposer-linux \
	https://github.com/ValaFoundation/vamposer/releases/latest/download/vamposer-linux
curl -fL -o vamposer-linux.sha256 \
	https://github.com/ValaFoundation/vamposer/releases/latest/download/vamposer-linux.sha256
sha256sum -c vamposer-linux.sha256
chmod +x vamposer-linux
sudo install -m 0755 vamposer-linux /usr/local/bin/vamposer
```

Verify installation:

```bash
vamposer --help
```

Self-upgrade the installed binary:

```bash
sudo vamposer self-upgrade
```

Manual uninstall:

```bash
sudo rm -f /usr/local/bin/vamposer
hash -r
```

### 🪟 Windows

Manual install (PowerShell):

```powershell
$InstallDir = Join-Path $env:LOCALAPPDATA 'Programs\Vamposer'
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$ExePath = Join-Path $InstallDir 'vamposer.exe'
$ChecksumPath = Join-Path $InstallDir 'vamposer.exe.sha256'

Invoke-WebRequest -Uri 'https://github.com/ValaFoundation/vamposer/releases/latest/download/vamposer.exe' -OutFile $ExePath
Invoke-WebRequest -Uri 'https://github.com/ValaFoundation/vamposer/releases/latest/download/vamposer.exe.sha256' -OutFile $ChecksumPath

$ExpectedHash = (Get-Content $ChecksumPath).Split(' ')[0].Trim().ToLower()
$ActualHash = (Get-FileHash -Algorithm SHA256 $ExePath).Hash.ToLower()
if ($ExpectedHash -ne $ActualHash) {
	throw 'Checksum verification failed.'
}

$UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($UserPath -split ';') -notcontains $InstallDir) {
	[Environment]::SetEnvironmentVariable('Path', ($UserPath.TrimEnd(';') + ';' + $InstallDir), 'User')
}
```

Verify installation (new terminal):

```powershell
vamposer --help
```

Self-upgrade:

```powershell
vamposer self-upgrade
```

Manual uninstall on Windows (PowerShell):

```powershell
$InstallDir = Join-Path $env:LOCALAPPDATA 'Programs\Vamposer'
$UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', (($UserPath -split ';' | Where-Object { $_ -and $_ -ne $InstallDir }) -join ';'), 'User')
Remove-Item -Recurse -Force $InstallDir
```

### 💻 CLI usage

Initialize a new project config:

```bash
vamposer init
```

Initialize with custom config path:

```bash
vamposer init path/to/vamposer.json
```

```bash
vamposer install
```

Install including development dependencies:

```bash
vamposer install --dev
```

Show CLI help:

```bash
vamposer --help
```

Show installed CLI version:

```bash
vamposer version
```

Install shell completion for current user:

```bash
vamposer completion install
```

On Linux, Vamposer also performs a best-effort completion auto-install on first run for bash/zsh.
Disable this behavior with `VAMPOSER_NO_AUTO_COMPLETION=1`.

Enable Bash completion (without install):

```bash
source completions/vamposer.bash
```

Enable Zsh completion (without install):

```bash
fpath=("$(pwd)/completions" $fpath)
autoload -Uz compinit && compinit
```

Upgrade the installed binary:

```bash
sudo vamposer self-upgrade
```

Disable colors if needed:

```bash
NO_COLOR=1 vamposer install
```

Add or update a dependency in config:

```bash
vamposer require github.com/ValaFoundation/testcases master
```

Add or update a development dependency in config:

```bash
vamposer require --dev github.com/ValaFoundation/testcases master
```

Remove a dependency from config:

```bash
vamposer remove github.com/ValaFoundation/testcases
```

Remove a development dependency from config:

```bash
vamposer remove --dev github.com/ValaFoundation/testcases
```

Force refresh all dependencies (re-clone):

```bash
vamposer update
```

Force refresh all dependencies including development dependencies:

```bash
vamposer update --dev
```

Force refresh one dependency:

```bash
vamposer update github.com/ValaFoundation/testcases
```

Force refresh one development dependency:

```bash
vamposer update --dev github.com/ValaFoundation/testcases
```

Custom config path:

```bash
vamposer install path/to/vamposer.json
```

Custom config path with development dependencies:

```bash
vamposer install --dev path/to/vamposer.json
```

## 📦 Release artifacts

Tag-based release workflow (`v*`) publishes:

- compatibility ZIP (`<repo-name>-<tag>-linux.zip`)
- standalone Linux binary (`vamposer-linux`) + checksum (`.sha256`)
- Debian package (`vamposer_<version>_amd64.deb`)
- RPM package (`vamposer-<version>-*.x86_64.rpm`)
- Ubuntu bundle (`vamposer-<tag>-ubuntu.tar.gz`) + raw CLI binary
- Fedora bundles (`vamposer-<tag>-fedora41.tar.gz` ... `fedora44`) + raw CLI binary
- Arch bundle (`vamposer-<tag>-arch.tar.gz`) + raw CLI binary
- Windows bundle (`vamposer-<tag>-windows.zip`) + `vamposer.exe`
- Flatpak bundle (`vamposer-<tag>-flatpak.flatpak`)

Current official release artifacts target `x86_64` only. Support for additional architectures will be considered once there is a concrete user need or issue requesting it.

## ⚙️ Config format

`vamposer.json` example:

```json
{
	"name": "com.github.ValaFoundation.my-app",
	"version": "1.0.0",
	"description": "Example app using Vamposer",
	"dependencies": {
		"github.com/ValaFoundation/testcases": "master",
		"github.com/ValaFoundation/downloader-lib": "master"
	},
	"dependencies-dev": {
		"github.com/ValaFoundation/dev-tools": "master"
	},
	"system_dependencies": {
		"gtk4": ">=4.10",
		"libadwaita-1": ">=1.4",
		"gee-0.8": "*"
	}
}
```

### 📝 Notes

- `dependencies` key is repository ID/path, value is tag/branch/revision.
- `dependencies-dev` key is for development-only Git dependencies, same value format as `dependencies`.
- Short form without protocol is preferred (`github.com/org/repo`) and is resolved as `https://<id>.git`.
- Full URLs are also supported, e.g. `https://github.com/org/repo` or `https://github.com/org/repo.git`.
- Works with GitHub, GitLab, Codeberg and self-hosted Git servers (domain/path format).
- Supported forms include `gitlab.com/group/project`, `https://gitlab.com/group/project`, `ssh://git@gitlab.com/group/project`, and `git@gitlab.com:group/project`.
- `system_dependencies` with `"*"` checks only package presence.

## 🧩 Meson integration

Generated `vamposer/meson.build` (project root) defines `vamposer_deps`:

```meson
vamposer_deps = [
	dependency('testcases', fallback: ['testcases', 'testcases_dep']),
	dependency('downloader-lib', fallback: ['downloader-lib', 'downloader_lib_dep'])
]
```

Use in your project `meson.build` (preferred):

```meson
# Loads vamposer/meson.build generated by Vamposer
subdir('vamposer')

executable('my-app',
	sources,
	dependencies: [
		dependency('gtk4'),
		dependency('libadwaita-1'),
		vamposer_deps
	]
)
```

Important: use this in the consumer app project where you run `vamposer install`.
Do not add `subdir('vamposer')` to this Vamposer tool repository itself.

Backward-compatible option (also generated):

```meson
subdir('subprojects/vamposer')
```

## 🛠️ Build

Build dependencies:

- tools: `meson`, `ninja`, `valac`, `pkg-config`
- Vala packages: `glib-2.0`, `gee-0.8`, `json-glib-1.0`
- runtime tools used by dependency operations: `git`, `pkg-config`

Install dependencies (examples):

### Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y \
	git \
	meson \
	ninja-build \
	valac \
	pkg-config \
	libglib2.0-dev \
	libgee-0.8-dev \
	libjson-glib-dev
```

### Fedora:

```bash
sudo dnf install -y \
	git \
	meson \
	ninja-build \
	vala \
	pkgconf-pkg-config \
	glib2-devel \
	libgee-devel \
	json-glib-devel
```

### Arch Linux:

```bash
sudo pacman -S --needed \
	git \
	meson \
	ninja \
	vala \
	pkgconf \
	glib2 \
	libgee \
	json-glib
```


### Building

```bash
make build
```

or

```bash
meson setup builddir
meson compile -C builddir
```


## ✅ Test

Test dependencies:

- `vala_testcases` (resolved from system if present, otherwise from `subprojects/vala_testcases` fallback)
- all Build dependencies above

```bash
meson test -C builddir --verbose
```

or

```bash
make tests
```

## 📄 License

Apache-2.0 (see `LICENSE` and `NOTICE`).
