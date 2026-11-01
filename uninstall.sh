#!/bin/bash

# Retro Save Manager (RSM) - Steam Deck Uninstaller
# Version: 0.1.1
# Author: SimonBits
# YouTube: @SimonBitsDev
# Bilibili: 大叔怀旧研究所
# License: GPL-3.0

set -u

PURGE=false

LANG_CN=false

for arg in "$@"; do
    case "$arg" in
        --purge)
            PURGE=true
            ;;
        --cn)
            LANG_CN=true
            ;;
        *)
            echo "Usage: $0 [--purge] [--cn]"
            exit 1
            ;;
    esac
done

RSM_NAME="Retro Save Manager"

INSTALL_DIR="$HOME/.local/share/retro-save-manager"
BIN_DIR="$INSTALL_DIR/bin"
CONFIG_DIR="$INSTALL_DIR/config"

SYSTEMD_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_DIR/rsm-syncthing.service"
SERVICE_NAME="rsm-syncthing.service"

# ------------------------------------------------------------
# Language
# ------------------------------------------------------------

if [ "$LANG_CN" = true ]; then

    MSG_UNINSTALLER="Steam Deck 卸载程序"

    MSG_PURGE_ENABLED="已启用完全删除模式。"
    MSG_PURGE_WARNING="Syncthing 配置和 Device ID 将被永久删除。"

    MSG_SERVICE_STOPPED="Syncthing 服务已停止"
    MSG_SERVICE_NOT_RUNNING="Syncthing 服务当前未运行"

    MSG_SERVICE_DISABLED="Syncthing 服务已禁用"
    MSG_SERVICE_NOT_ENABLED="Syncthing 服务当前未启用"

    MSG_SYSTEMD_REMOVED="systemd 用户服务已删除"
    MSG_SYSTEMD_NOT_FOUND="未找到 systemd 用户服务"

    MSG_PROGRAM_REMOVED="RSM 程序文件已删除"
    MSG_PROGRAM_NOT_FOUND="未找到 RSM 程序文件"

    MSG_NOTICES_REMOVED="许可证及第三方文件已删除"

    MSG_CONFIG_REMOVED="Syncthing 配置已删除"
    MSG_CONFIG_NOT_FOUND="未找到 Syncthing 配置"
    MSG_CONFIG_PRESERVED="Syncthing 配置已保留"

    MSG_COMPLETED="卸载完成"
    MSG_RSM_REMOVED="RSM 已删除。"
    MSG_PURGE_REMOVED="RSM 配置和 Syncthing Device ID 也已删除。"
    MSG_PRESERVED="Syncthing 配置已保留。"

else

    MSG_UNINSTALLER="Steam Deck Uninstaller"

    MSG_PURGE_ENABLED="Purge mode enabled."
    MSG_PURGE_WARNING="Syncthing configuration and Device ID will be permanently deleted."

    MSG_SERVICE_STOPPED="Syncthing service stopped"
    MSG_SERVICE_NOT_RUNNING="Syncthing service is not running"

    MSG_SERVICE_DISABLED="Syncthing service disabled"
    MSG_SERVICE_NOT_ENABLED="Syncthing service is not enabled"

    MSG_SYSTEMD_REMOVED="systemd user service removed"
    MSG_SYSTEMD_NOT_FOUND="systemd user service was not found"

    MSG_PROGRAM_REMOVED="RSM program files removed"
    MSG_PROGRAM_NOT_FOUND="RSM program files were not found"

    MSG_NOTICES_REMOVED="License and third-party files removed"

    MSG_CONFIG_REMOVED="Syncthing configuration removed"
    MSG_CONFIG_NOT_FOUND="Syncthing configuration was not found"
    MSG_CONFIG_PRESERVED="Syncthing configuration preserved"

    MSG_COMPLETED="Uninstallation completed"
    MSG_RSM_REMOVED="RSM has been removed."
    MSG_PURGE_REMOVED="RSM configuration and Syncthing Device ID have also been removed."
    MSG_PRESERVED="Your Syncthing configuration has been preserved."

fi

ok() {
    echo "[ OK ] $1"
}

warn() {
    echo "[WARN] $1"
}

echo
echo "========================================"
echo "  $RSM_NAME - $MSG_UNINSTALLER"
echo "========================================"
echo

if [ "$PURGE" = true ]; then

    echo "[WARN] $MSG_PURGE_ENABLED"
    echo "[WARN] $MSG_PURGE_WARNING"
    echo

fi

# ------------------------------------------------------------
# Stop and disable service
# ------------------------------------------------------------

if systemctl --user is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    systemctl --user stop "$SERVICE_NAME"
    ok "$MSG_SERVICE_STOPPED"
else
    warn "$MSG_SERVICE_NOT_RUNNING"
fi

if systemctl --user is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    systemctl --user disable "$SERVICE_NAME" >/dev/null 2>&1
    ok "$MSG_SERVICE_DISABLED"
else
    warn "$MSG_SERVICE_NOT_ENABLED"
fi

# ------------------------------------------------------------
# Remove systemd service
# ------------------------------------------------------------

if [ -f "$SERVICE_FILE" ]; then
    rm -f "$SERVICE_FILE"
    ok "$MSG_SYSTEMD_REMOVED"
else
    warn "$MSG_SYSTEMD_NOT_FOUND"
fi

systemctl --user daemon-reload
systemctl --user reset-failed >/dev/null 2>&1 || true

# ------------------------------------------------------------
# Remove program files
# ------------------------------------------------------------

if [ -d "$BIN_DIR" ]; then

    rm -rf "$BIN_DIR"
    ok "$MSG_PROGRAM_REMOVED"

else

    warn "$MSG_PROGRAM_NOT_FOUND"

fi

# ------------------------------------------------------------
# Remove license and third-party files
# ------------------------------------------------------------

rm -f "$INSTALL_DIR/LICENSE"
rm -f "$INSTALL_DIR/THIRD_PARTY_NOTICES.md"
rm -f "$INSTALL_DIR/SYNCTHING-LICENSE.txt"
rm -f "$INSTALL_DIR/SYNCTHING-AUTHORS.txt"

ok "$MSG_NOTICES_REMOVED"

# ------------------------------------------------------------
# Handle configuration
# ------------------------------------------------------------

CONFIG_PRESERVED=false

if [ "$PURGE" = true ]; then

    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        ok "$MSG_CONFIG_REMOVED"
    else
        warn "$MSG_CONFIG_NOT_FOUND"
    fi

else

    if [ -d "$CONFIG_DIR" ]; then
        ok "$MSG_CONFIG_PRESERVED"
        echo "      $CONFIG_DIR"
        CONFIG_PRESERVED=true
    fi

fi

# Remove installation directory only if empty.

rmdir "$INSTALL_DIR" 2>/dev/null || true

echo
echo "========================================"
echo "  $MSG_COMPLETED"
echo "========================================"
echo
echo "$MSG_RSM_REMOVED"

if [ "$PURGE" = true ]; then
    echo "$MSG_PURGE_REMOVED"
elif [ "$CONFIG_PRESERVED" = true ]; then
    echo "$MSG_PRESERVED"
fi

echo
