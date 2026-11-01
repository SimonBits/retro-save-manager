# Retro Save Manager (RSM) for Steam Deck

RSM **v0.1.1** · Syncthing **v2.1.7**

Release platforms: Steam Deck AMD64 and [Armada OS ARM64](armada/README.md).
H700 is not included in this release.

**English | [简体中文](README-CN.md)**

Retro Save Manager (RSM) is a lightweight save synchronization solution
for Steam Deck.

RSM uses [Syncthing](https://syncthing.net/) to synchronize game save
folders between your Steam Deck and other devices.

After installation, Syncthing runs automatically in the background as a
systemd user service. You do not need to manually start Syncthing each
time you use your Steam Deck.

## Features

-   Automatic Syncthing startup with Steam Deck
-   Runs as a systemd user service
-   Web-based Syncthing configuration
-   LAN access to the Syncthing Web UI
-   Independent RSM Syncthing configuration
-   Does not modify an existing Syncthing configuration
-   Configuration is preserved after uninstall
-   Reinstallation keeps the same Syncthing Device ID
-   No Decky Plugin required

## Supported Platform

The original v0.1.0 implementation was validated on the following platform.
The user has confirmed hardware validation of this v0.1.1 package with the
unchanged v2.1.7 payload:

-   Steam Deck
-   SteamOS
-   x86_64

Bundled Syncthing version:

-   Syncthing v2.1.7

Armada OS ARM64 is supported by the separate Armada package described in
[its README](armada/README.md). Other platforms are outside this release scope.

## Installation

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

Syncthing is enabled and started automatically.

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

If you do not want to configure a username and password for the Syncthing Web UI,
you can stop the RSM service when synchronization is not needed:

```bash
systemctl --user stop rsm-syncthing.service
```

Start it again when synchronization is needed:

```bash
systemctl --user start rsm-syncthing.service
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
configuration on your Steam Deck.

## Uninstallation

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
