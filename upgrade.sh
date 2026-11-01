#!/bin/bash
# RSM v0.1.1 — offline Syncthing upgrade (Steam Deck)
set -Eeuo pipefail

EXPECTED_ARCH=x86_64
GO_ARCH=amd64
CN=false
case "${1:-}" in
    --cn) CN=true ;;
    '') ;;
    *) echo "Usage: $0 [--cn]"; exit 1 ;;
esac
[ "$#" -le 1 ] || { echo "Usage: $0 [--cn]"; exit 1; }
say() { if "$CN"; then printf '%s\n' "$2"; else printf '%s\n' "$1"; fi; }
die() { say "$1" "$2" >&2; exit 1; }

PACKAGE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT="$HOME/.local/share/retro-save-manager"
BIN="$ROOT/bin/syncthing"
UNIT="$HOME/.config/systemd/user/rsm-syncthing.service"
SERVICE=rsm-syncthing.service
FILES=(bin/syncthing LICENSE THIRD_PARTY_NOTICES.md SYNCTHING-LICENSE.txt SYNCTHING-AUTHORS.txt)
SOURCES=(payload/syncthing LICENSE THIRD_PARTY_NOTICES.md payload/SYNCTHING-LICENSE.txt payload/SYNCTHING-AUTHORS.txt)
BACKUP=''
STAGE=''
WAS_ACTIVE=false
STOP_REQUESTED=false
MUTATING=false
START_ATTEMPTED=false

state() { systemctl --user show "$SERVICE" -p ActiveState --value; }
# Conservatively require all of this user's Syncthing processes to be gone.
# Never kill another instance or assume an inactive unit means no process exists.
stopped() {
    local current rc
    current=$(state) || return 1
    [ "$current" = inactive ] || return 1
    if pgrep -u "$(id -u)" -x syncthing >/dev/null; then return 1; else rc=$?; fi
    [ "$rc" -eq 1 ]
}
version() {
    local output
    output=$("$1" --version) || return 1
    [[ "$output" =~ ^syncthing\ (v[0-9]+\.[0-9]+\.[0-9]+)\  ]] || return 1
    printf '%s\n' "${BASH_REMATCH[1]}"
}
ready() {
    local pid sockets exe expected
    [ "$(state)" = active ] || return 1
    expected=$(readlink -f "$BIN") || return 1
    pid=$(systemctl --user show "$SERVICE" -p MainPID --value) || return 1
    [[ "$pid" =~ ^[1-9][0-9]*$ ]] || return 1
    exe=$(readlink -f "/proc/$pid/exe") || return 1
    [ "$exe" = "$expected" ] || return 1
    [ "$(version "/proc/$pid/exe")" = "$NEW_VERSION" ] || return 1
    sockets=$(ss -H -lntp 'sport = :8384') || return 1
    # Syncthing's monitor can be MainPID while its child owns the listener.
    for pid in $(pgrep -u "$(id -u)" -x syncthing); do
        exe=$(readlink -f "/proc/$pid/exe") || continue
        if [ "$exe" = "$expected" ] && [[ "$sockets" == *"pid=$pid,"* ]]; then return 0; fi
    done
    return 1
}
finish() {
    local rc=$? restored=true f
    trap - EXIT INT TERM
    if [ "$rc" -ne 0 ]; then
        say "Upgrade failed (exit $rc)." "升级失败（退出码 $rc）。" >&2
        if "$START_ATTEMPTED"; then
            # Even a failed start request may already have launched the new binary.
            # It may have migrated the database. Never restore just the old binary.
            systemctl --user stop "$SERVICE" || true
            say "Upgrade not verified. New files retained; NO automatic downgrade after a start attempt. Inspect logs and database compatibility before recovery." \
                "升级未验证成功。保留新文件；尝试启动后不会自动降级。恢复前请检查日志及数据库兼容性。" >&2
            stopped || say "WARNING: service/process stop could not be confirmed." "警告：无法确认服务及进程已停止。" >&2
        else
            if "$MUTATING"; then
                if stopped; then
                    for f in "${FILES[@]}"; do
                        if ! cp -p -- "$BACKUP/$f" "$STAGE/restore" || ! mv -f -- "$STAGE/restore" "$ROOT/$f"; then
                            restored=false
                        fi
                    done
                else
                    restored=false
                fi
                if "$restored"; then
                    say "Original binary and notices restored." "已恢复原二进制和声明文件。" >&2
                else
                    say "Recovery incomplete; keep service stopped and inspect the backup." "恢复未完成；请保持服务停止并检查备份。" >&2
                fi
            fi
            if "$WAS_ACTIVE" && "$STOP_REQUESTED" && "$restored" && stopped; then
                systemctl --user start "$SERVICE" || say "Could not restart original service." "无法重新启动原服务。" >&2
            fi
        fi
        [ -z "$BACKUP" ] || printf 'Backup: %s\n' "$BACKUP" >&2
    fi
    # Keep failed staging material for inspection; successful staging is empty.
    if [ "$rc" -eq 0 ] && [ -n "$STAGE" ]; then rmdir -- "$STAGE" || true; fi
    exit "$rc"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

[ "$(id -u)" -ne 0 ] || die "Run as the installing user, without sudo." "请使用原安装用户运行，不要使用 sudo。"
[ "$(uname -m)" = "$EXPECTED_ARCH" ] || die "Wrong architecture for this package." "系统架构与安装包不匹配。"
# No installation artifacts at all is a normal no-op. Retained config,
# empty/partial directories, dangling symlinks or an enablement link are not.
ENABLE_LINK="$HOME/.config/systemd/user/default.target.wants/$SERVICE"
if [ ! -e "$ROOT" ] && [ ! -L "$ROOT" ] && \
   [ ! -e "$UNIT" ] && [ ! -L "$UNIT" ] && \
   [ ! -e "$ENABLE_LINK" ] && [ ! -L "$ENABLE_LINK" ]; then
    say "[ INFO ] RSM is not installed. Run install.sh first." "[ INFO ] 未安装 RSM，请先运行 install.sh 完成安装。"
    say "[ INFO ] No installation found. No upgrade needed." "[ INFO ] 未安装，无需升级。"
    exit 0
fi
for cmd in systemctl pgrep ss readlink sha256sum flock sort mktemp cp mv install cmp; do
    command -v "$cmd" >/dev/null || die "Missing command: $cmd" "缺少命令：$cmd"
done
[ -d "$ROOT/bin" ] && [ -f "$ROOT/config/config.xml" ] && [ -f "$UNIT" ] || die "Existing RSM installation required. Use install.sh for a first install." "未找到完整 RSM 安装；首次安装请使用 install.sh。"
for f in "${FILES[@]}"; do
    [ -f "$ROOT/$f" ] && [ ! -L "$ROOT/$f" ] || die "Missing or symlinked installed file: $f" "已安装文件缺失或为符号链接：$f"
done
[ ! -L "$ROOT/bin" ] && [ ! -L "$ROOT" ] && [ ! -L "$UNIT" ] || die "Symlinked installation not supported." "不支持符号链接形式的安装。"
[ -x "$BIN" ] && [ -x "$PACKAGE/payload/syncthing" ] || die "Executable binary required." "二进制必须具有可执行权限。"
(cd "$PACKAGE" && sha256sum --check --status SHA256SUMS) || die "Package checksum verification failed." "安装包校验失败。"
exec 9>"$ROOT/.upgrade.lock"
flock -n 9 || die "Another upgrade is running." "已有升级正在运行。"
systemctl --user show-environment >/dev/null
# Do not upgrade an unrelated/custom service or a different configuration tree.
EXEC=$(systemctl --user show "$SERVICE" -p ExecStart --value)
[[ "$EXEC" == *"$BIN "* && "$EXEC" == *"--home=$ROOT/config"* ]] || die "Unexpected service ExecStart; inspect it before upgrading." "服务 ExecStart 与 RSM 不符，请先检查。"
INITIAL_STATE=$(state)
case "$INITIAL_STATE" in
    active) WAS_ACTIVE=true ;;
    inactive) ;;
    *) die "Service is not stably active/inactive; resolve its state first." "服务不处于稳定的运行或停止状态，请先排查。" ;;
esac
NEW_OUTPUT=$("$PACKAGE/payload/syncthing" --version)
[[ "$NEW_OUTPUT" == *"linux-$GO_ARCH"* ]] || die "Payload reports the wrong architecture." "payload 报告的架构不符。"
NEW_VERSION=$(version "$PACKAGE/payload/syncthing")
OLD_VERSION=$(version "$BIN")
[ "$(printf '%s\n' "$OLD_VERSION" "$NEW_VERSION" | sort -V | head -n 1)" = "$OLD_VERSION" ] || die "Downgrades are not supported." "不支持降级。"
if [ "$OLD_VERSION" = "$NEW_VERSION" ] && ! cmp -s "$BIN" "$PACKAGE/payload/syncthing"; then
    die "Same version but different binary; refusing an ambiguous replacement." "版本相同但二进制不同，拒绝不明确的替换。"
fi
IDENTICAL=true
for i in "${!FILES[@]}"; do
    cmp -s "$ROOT/${FILES[$i]}" "$PACKAGE/${SOURCES[$i]}" || IDENTICAL=false
done
if "$IDENTICAL"; then
    say "[ OK ] Already up to date. No upgrade needed." "[ OK ] 当前已安装最新版本，无需升级。"
    exit 0
fi
printf 'Syncthing: %s -> %s\n' "$OLD_VERSION" "$NEW_VERSION"
STOP_REQUESTED=true
systemctl --user stop "$SERVICE"
stopped || die "Service or Syncthing processes remain; no files replaced." "服务或 Syncthing 进程仍存在；未替换文件。"
umask 077
BACKUP=$(mktemp -d "$ROOT/upgrade-backup-XXXXXXXX")
mkdir -p "$BACKUP/bin"
for f in "${FILES[@]}"; do cp -p -- "$ROOT/$f" "$BACKUP/$f"; done
cp -p -- "$UNIT" "$BACKUP/rsm-syncthing.service"
printf 'Backup: %s\n' "$BACKUP"
# Stage on the installation filesystem; rename rather than truncate the binary.
STAGE=$(mktemp -d "$ROOT/.upgrade-stage-XXXXXXXX")
for i in "${!FILES[@]}"; do
    mode=0644
    [ "$i" -ne 0 ] || mode=0755
    install -m "$mode" -- "$PACKAGE/${SOURCES[$i]}" "$STAGE/$i"
done
stopped || die "A process restarted during staging; refusing replacement." "准备期间进程重新启动，拒绝替换。"
MUTATING=true
for i in "${!FILES[@]}"; do mv -f -- "$STAGE/$i" "$ROOT/${FILES[$i]}"; done
[ "$(version "$BIN")" = "$NEW_VERSION" ]
if ! "$WAS_ACTIVE"; then
    say "Upgrade complete. Service remains stopped; runtime/Web UI checks deferred until you start it." "升级完成。服务保持停止；运行及 Web UI 检查留待手动启动后进行。"
    exit 0
fi
START_ATTEMPTED=true
systemctl --user start "$SERVICE"
DEADLINE=$((SECONDS + 30))
while ! ready; do
    [ "$SECONDS" -lt "$DEADLINE" ] || die "Service/process/version or TCP 8384 not ready within 30 seconds." "30 秒内服务、进程、版本或 TCP 8384 未就绪。"
    sleep 1
done
say "Upgrade complete: $NEW_VERSION, service running and TCP 8384 ready." "升级完成：$NEW_VERSION，服务运行且 TCP 8384 已就绪。"
