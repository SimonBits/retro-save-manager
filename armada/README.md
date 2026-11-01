# Retro Save Manager (RSM) for Armada OS

RSM **v0.1.1** · Syncthing **v2.1.7**

H700 is not included in this release.

**English | [简体中文](README-CN.md)**

Retro Save Manager (RSM) is a lightweight save synchronization solution
for Armada OS.

RSM uses [Syncthing](https://syncthing.net/) to synchronize game save
folders between your Armada OS and other devices.

After installation, Syncthing runs automatically in the background as a
systemd user service. You do not need to manually start Syncthing each
time you use your Armada OS.

## Features

-   Automatic Syncthing startup with Armada OS
-   Runs as a systemd user service
-   Web-based Syncthing configuration
-   LAN access to the Syncthing Web UI
-   Independent RSM Syncthing configuration
-   Does not modify an existing Syncthing configuration
-   Configuration is preserved after uninstall
-   Reinstallation keeps the same Syncthing Device ID
-   No Decky Plugin required

## Supported Platform

Target platform for this package:

-   Armada OS
-   aarch64 (ARM64)

The user has confirmed that Armada OS ARM64 v0.1.1 passed hardware validation,
including installation, startup, reboot recovery and upgrade. This does not
claim separate validation of mode switching or OS updates.

Bundled Syncthing version:

-   Syncthing v2.1.7

Other platforms are outside the scope of this package.

## Installation

### Choose the correct package

RSM version: **v0.1.1**, with Syncthing **v2.1.7** on both platforms.

| Platform | Package | Installation |
| --- | --- | --- |
| Steam Deck / SteamOS x86_64 | `RSM-SteamDeck-v0.1.1.zip` (v0.1.1; historical v0.1.0 asset unchanged) | Extract that package and run `./install.sh` |
| Armada OS ARM64 | `RSM-ArmadaOS-v0.1.1.zip` (v0.1.1; hardware validated) | Extract this package and run `./install.sh` |

Project: https://github.com/SimonBits/retro-save-manager

Existing Steam Deck release: https://github.com/SimonBits/retro-save-manager/releases/tag/v0.1.0

Use each package's own installer and payload. This ARM64 package cannot be
installed on Steam Deck. Both packages support `--cn` and the service commands
documented below. No additional platform packages are provided here.

### Armada OS

Open a terminal in Armada's normal desktop user session. Run the installer
as your regular user, **without sudo**, on the native host (not inside FEX,
Distrobox or another container). The installer requires `uname -m` to report
`aarch64` and an accessible `systemd --user` manager.

Extract the RSM package.

Open a terminal inside the extracted directory and run:

``` bash
chmod +x install.sh
./install.sh
```

For Simplified Chinese installer output, run `./install.sh --cn`.

The installer performs several pre-checks before installation,
including:

-   CPU architecture
-   systemd user session
-   required system tools
-   existing RSM installation
-   existing Syncthing process
-   Syncthing payload
-   TCP port 8384
-   TCP/UDP port 22000
-   UDP port 21027

After installation, RSM installs Syncthing under:

``` text
~/.local/share/retro-save-manager/
```

and creates the systemd user service:

``` text
~/.config/systemd/user/rsm-syncthing.service
```

Syncthing is enabled and started automatically. The installer checks service
state and TCP 8384 immediately, then once per second for up to 30 seconds. It
returns as soon as both are ready. A running service without a listener after
30 seconds produces an explicit warning; an inactive service is an error.
A listening port does not prove LAN reachability or an HTTP response.

All RSM files are installed under `$HOME`; the default Armada home is
`/var/home/armada`. The package bundles the official Linux ARM64 executable
and does not install system packages, remount system partitions, modify Steam
or Gamescope, or change OS update settings.

The service is enabled for the user's `default.target`. It is intended to
start with the user session in either mode; this is not a promise of startup
before login. The installer does not enable lingering. Mode switching still requires hardware verification. User data under `/var/home`
is expected to persist across bootc updates, but this has not been tested here.

Store saves outside `~/.local/share/retro-save-manager/`. Select their actual
paths in the Web UI; RSM does not discover emulator save paths automatically.

## First-Time Setup

After installation, the installer displays the Web UI address, for
example:

``` text
http://192.168.1.100:8384
```

Open this address from a computer, phone, or other device on the same
local network.

You can then use the Syncthing Web UI to:

-   Add remote devices
-   Create shared folders
-   Select your game save directories
-   Check synchronization status

## Web UI and Security

RSM configures the Syncthing Web UI to listen on:

``` text
0.0.0.0:8384
```

This allows another device on your local network to access the Syncthing
configuration interface.

Because the Web UI is accessible over the local network, it is strongly
recommended that you configure a GUI username and password in Syncthing.

Do not intentionally expose port 8384 directly to the public Internet.

You can stop the RSM service when synchronization is not needed. This is not
a substitute for setting Web UI credentials while the service is running:

```bash
systemctl --user stop rsm-syncthing.service
```

Start it again when synchronization is needed:

```bash
systemctl --user start rsm-syncthing.service
```

Stopping the service does not disable startup on the next user session.
To disable automatic startup and stop it, use:

```bash
systemctl --user disable --now rsm-syncthing.service
```

To restore automatic startup and start it, use:

```bash
systemctl --user enable --now rsm-syncthing.service
```

## Save Synchronization

RSM provides file synchronization.

It does **not** convert save formats between emulators, emulator cores,
operating systems, or different versions of a game.

For the best results, use compatible environments on all synchronized
devices.

Pay particular attention to:

-   Emulator or RetroArch core
-   ROM/game filename
-   Save filename
-   Save extension
-   Save directory
-   Emulator-specific save format

For example, two devices may both run the same GBA game while using
different emulator cores or different save locations.

RSM cannot automatically resolve these compatibility differences.

## Save States

Synchronizing normal in-game save files is recommended.

Synchronizing emulator Save States is **not recommended**.

Save States may depend on the exact emulator/core version and runtime
state, making them considerably less portable than normal game saves.

## Syncthing Conflicts

If the same save file is modified independently on multiple devices
before synchronization completes, Syncthing may create a conflict file.

To reduce the chance of conflicts:

1.  Finish playing on one device.
2.  Exit the game/emulator normally.
3.  Allow synchronization to complete.
4.  Start playing on the other device.

Avoid playing and modifying the same synchronized save simultaneously on
multiple devices.

## RSM Configuration

RSM uses its own Syncthing configuration directory:

``` text
~/.local/share/retro-save-manager/config/
```

This configuration is separate from a normal standalone Syncthing
installation.

RSM therefore does not need to modify or reuse an existing Syncthing
configuration on your Armada OS.

## Uninstallation

Run the uninstaller as the same regular user who installed RSM, without sudo.
Normal uninstall preserves configuration and identity. Keep save folders
outside RSM's installation directory; `--purge` deletes its configuration
directory recursively and must not be used if you want to retain Device ID.

Run:

``` bash
chmod +x uninstall.sh
./uninstall.sh
```

For Simplified Chinese uninstaller output, add `--cn`.

The uninstaller:

-   Stops the RSM Syncthing service
-   Disables automatic startup
-   Removes the systemd user service
-   Removes the RSM Syncthing program files

Your RSM Syncthing configuration is preserved by default.

The preserved configuration is located at:

``` text
~/.local/share/retro-save-manager/config/
```

### Complete Removal

By default, RSM preserves the Syncthing configuration and Device ID.

To completely remove RSM, including the Syncthing configuration, Device
ID, certificates, device settings, folder settings, and synchronization
database, run:

``` bash
chmod +x uninstall.sh
./uninstall.sh --purge
```

For Simplified Chinese uninstaller output, run
`./uninstall.sh --purge --cn`.

**Warning: This operation permanently deletes the RSM Syncthing
configuration and cannot be undone.**

## Offline upgrade (`upgrade.sh`)

RSM version: **v0.1.1**, bundling official Syncthing **v2.1.7**. Steam Deck AMD64 and
Armada OS ARM64 have both passed user hardware validation. The historical
v0.1.0 Release remains unchanged.

| Task | Command | Effect |
| --- | --- | --- |
| First installation | `./install.sh` | Installs and enables the user service; refuses an existing installation |
| Offline upgrade | `./upgrade.sh` | Replaces the installed program and notices from this package |
| Normal uninstall | `./uninstall.sh` | Removes the service/program; preserves configuration and identity |

All three accept `--cn`. **Never use `--purge` to upgrade.** It deletes identity
and configuration. Upgrade does not need uninstall/reinstall.

Choose the package for your platform: `RSM-SteamDeck-v0.1.1.zip` for AMD64 or
`RSM-ArmadaOS-v0.1.1.zip` for ARM64. Check its supplied ZIP SHA-256, then extract
to a separate directory, not the installed RSM directory. Close games and let
synchronization finish. Run as the original installing user, without sudo:

```bash
./upgrade.sh
```

The upgrader verifies package checksums, architecture, existing installation,
service command and stable Syncthing versions. It rejects downgrades, a different
binary with the same version, nonstandard/symlinked installations and unstable
service states. Concurrent upgrades are locked. Identical program/notices are a
no-op; no service restart occurs. The scripts do not download anything.

When already up to date, the script prints:

```text
[ OK ] Already up to date. No upgrade needed.
```

When no RSM installation directory, user unit or enablement link exists, it
prints the following and exits successfully (code 0), without service changes:

```text
[ INFO ] RSM is not installed. Run install.sh first.
[ INFO ] No installation found. No upgrade needed.
```

Incomplete installations still fail with a nonzero exit code. This includes
retained configuration after normal uninstall, an empty installation directory,
missing required files or dangling unit/enablement symlinks. Use `install.sh`
for a normal reinstall with retained configuration; do not use `--purge`.

It stops the user service and requires it to be inactive with no Syncthing
processes remaining for that user. Other instances are never killed: stop them
separately before retrying. It backs up the old binary, notices and unit under
`~/.local/share/retro-save-manager/upgrade-backup-*`, then stages files on the
same filesystem and renames them into place. The service unit and enablement
are not changed. Configuration, database, Device ID and synchronized folders are
not copied, deleted, reset or edited by the upgrader. Backups here are **program
backups, not database/save backups**. Normal Syncthing startup/synchronization
can still write configuration, migrate its database or synchronize files.

If the service was running, it is restarted and checked for up to 30 seconds:
active service, matching running executable/version, and a TCP 8384 listener
owned by that executable. This does not test HTTP or LAN reachability. If the
service was stopped, it remains stopped; runtime/Web UI validation is explicitly
deferred until you start it manually. No enable/disable operation is performed.

Before any attempt to start the new version, failure triggers best-effort
restoration of the old binary/notices and the prior running state. **After a new
start attempt, failure never automatically downgrades the binary**: the database
may already have migrated, even when systemctl reports failure. The upgrader
tries to stop the service, leaves the new files and program backup in place,
prints a warning and exits unsuccessfully. Do not manually restore only the old
binary. Inspect logs and database compatibility first; a full data rollback
requires your own compatible offline backup. If stopping fails, it reports that
process shutdown could not be confirmed. Interrupted staging may be retained
for inspection; SIGKILL/power loss cannot be automatically recovered by a trap.

After upgrading, verify:

```bash
systemctl --user status rsm-syncthing.service --no-pager
journalctl --user -u rsm-syncthing.service -b -n 80 --no-pager
"$HOME/.local/share/retro-save-manager/bin/syncthing" --version
```

Check Web UI, Device ID and shared folders. For a previously stopped service,
start it only when you intend to resume synchronization:

```bash
systemctl --user start rsm-syncthing.service
```

## Reinstallation

If RSM is installed again after a normal uninstall, the installer
detects the preserved configuration and reuses it.

This means your existing Syncthing identity and configuration can be
retained, including the Syncthing Device ID.

## Network Ports

Syncthing normally uses the following ports:

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8384 | TCP | Web UI |
| 22000 | TCP | Sync traffic |
| 22000 | UDP | QUIC sync traffic |
| 21027 | UDP | Local discovery |

RSM checks these ports during installation.

A conflict on TCP port 8384 prevents installation because RSM uses this port for the Syncthing Web UI.

Other Syncthing-related port conflicts may be reported as warnings.

## Troubleshooting

If a required command or user session is unavailable, use the native desktop
terminal and resolve the reported prerequisite before retrying. Do not disable
the read-only system or alter Steam/Gamescope services to install RSM.

The existing installer refuses installation if another Syncthing process is
running or TCP 8384 is occupied. Separate configuration does not make those
instances safe to run on the same ports. A listening Web UI may still be blocked
by the network or firewall; the installer does not change firewall rules.

Check the RSM service:

``` bash
systemctl --user status rsm-syncthing.service
```

Restart it:

``` bash
systemctl --user restart rsm-syncthing.service
```

View service logs:

``` bash
journalctl --user -u rsm-syncthing.service
```

Check whether the Web UI is listening:

``` bash
ss -lntp | grep 8384
```

## About RSM

Retro Save Manager is created by **SimonBits**.

YouTube: **@SimonBitsDev**

Bilibili: **大叔怀旧研究所**

RSM focuses on making save synchronization easier across retro gaming
devices while keeping the underlying process transparent and
understandable.

## License

Retro Save Manager is licensed under the GNU General Public License v3.0
(GPL-3.0).

See:

``` text
LICENSE
```

for the full license text.

## Third-Party Software

RSM includes Syncthing as third-party software.

Syncthing is a separate open-source project and is distributed under the
Mozilla Public License 2.0 (MPL-2.0).

See:

``` text
THIRD_PARTY_NOTICES.md
payload/SYNCTHING-LICENSE.txt
payload/SYNCTHING-AUTHORS.txt
```

for additional information.

Syncthing project:

https://syncthing.net/

Syncthing source code:

https://github.com/syncthing/syncthing
