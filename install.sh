#!/bin/bash

# Retro Save Manager (RSM) - Steam Deck Installer
# Version: 0.1.1
# Author: SimonBits
# YouTube: @SimonBitsDev
# Bilibili: 大叔怀旧研究所
# License: GPL-3.0
#
# RSM provides save synchronization using Syncthing.
# Syncthing is a separate open-source project and is
# distributed under its own license.

set -u

LANG_CN=false

if [ "${1:-}" = "--cn" ]; then
    LANG_CN=true
elif [ $# -gt 0 ]; then
    echo "Usage: $0 [--cn]"
    exit 1
fi

RSM_NAME="Retro Save Manager"
RSM_VERSION="0.1.1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD="$SCRIPT_DIR/payload/syncthing"

RSM_LICENSE="$SCRIPT_DIR/LICENSE"
THIRD_PARTY_NOTICE="$SCRIPT_DIR/THIRD_PARTY_NOTICES.md"
SYNCTHING_LICENSE="$SCRIPT_DIR/payload/SYNCTHING-LICENSE.txt"
SYNCTHING_AUTHORS="$SCRIPT_DIR/payload/SYNCTHING-AUTHORS.txt"

INSTALL_DIR="$HOME/.local/share/retro-save-manager"
BIN_DIR="$INSTALL_DIR/bin"
CONFIG_DIR="$INSTALL_DIR/config"

SYSTEMD_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_DIR/rsm-syncthing.service"
SERVICE_NAME="rsm-syncthing.service"

SYNCTHING_BIN="$BIN_DIR/syncthing"

# ------------------------------------------------------------
# Language
# ------------------------------------------------------------

if [ "$LANG_CN" = true ]; then

    MSG_PRECHECK="安装前检查"
    MSG_INSTALLING="正在安装"
    MSG_POSTCHECK="安装后检查"

    MSG_ARCH="系统架构"
    MSG_TOOLS="必需的系统工具可用"
    MSG_SYSTEMD="systemd 用户会话可用"
    MSG_PAYLOAD="已找到 Syncthing 安装文件"
    MSG_LICENSES="已找到许可证及第三方声明"

    MSG_EXISTING_RSM="检测到已有 RSM 安装"
    MSG_PREVIOUS_CONFIG="检测到之前的 RSM 配置"
    MSG_NO_RSM="未检测到已有 RSM 安装"

    MSG_RUNNING_SYNCTHING="检测到正在运行的 Syncthing"
    MSG_NO_SYNCTHING="未检测到正在运行的 Syncthing"

    MSG_PORT_AVAILABLE="可用"
    MSG_PORT_IN_USE="已被占用"

    MSG_DIRS_CREATED="安装目录创建完成"
    MSG_SYNCTHING_INSTALLED="Syncthing 安装完成"
    MSG_NOTICES_INSTALLED="许可证及第三方声明安装完成"

    MSG_CONFIG_PRESERVED="已保留之前的 Syncthing 配置"
    MSG_CONFIG_GENERATED="Syncthing 配置生成完成"
    MSG_GUI_ALREADY="Syncthing Web UI 已配置为允许局域网访问"
    MSG_GUI_CONFIGURED="Syncthing Web UI 已配置为允许局域网访问"

    MSG_SERVICE_INSTALLED="systemd 用户服务安装完成"
    MSG_SERVICE_RUNNING="Syncthing 服务正在运行"
    MSG_GUI_LISTENING="Syncthing Web UI 正在监听 TCP 8384"

    MSG_COMPLETED="安装完成"
    MSG_RUNNING="运行中"
    MSG_AUTOSTART="RSM 将随 Steam Deck 自动启动。"

    MSG_UNSUPPORTED_ARCH="不支持的系统架构"
    MSG_X86_REQUIRED="需要 x86_64"
    MSG_COMMAND_NOT_FOUND="未找到必需的系统命令"
    MSG_SYSTEMD_UNAVAILABLE="systemd 用户会话不可用"
    MSG_PAYLOAD_NOT_FOUND="未找到 Syncthing 安装文件"
    MSG_PAYLOAD_NOT_EXECUTABLE="Syncthing 安装文件不可执行"
    MSG_DIST_FILE_NOT_FOUND="未找到必需的发行文件"

    MSG_RSM_ALREADY_INSTALLED="检测到已有 RSM 安装"
    MSG_SYNCTHING_ALREADY_RUNNING="检测到正在运行的 Syncthing"

    MSG_PORT_IN_USE="已被占用"
    MSG_PORT_NOT_DETECTED="启动后未检测到 TCP 8384"

    MSG_CREATE_INSTALL_DIR_FAILED="无法创建安装目录"
    MSG_CREATE_CONFIG_DIR_FAILED="无法创建配置目录"
    MSG_CREATE_SYSTEMD_DIR_FAILED="无法创建 systemd 用户目录"

    MSG_INSTALL_SYNCTHING_FAILED="无法安装 Syncthing"
    MSG_CHMOD_SYNCTHING_FAILED="无法设置 Syncthing 可执行权限"

    MSG_INSTALL_RSM_LICENSE_FAILED="无法安装 RSM 许可证"
    MSG_INSTALL_NOTICE_FAILED="无法安装第三方声明"
    MSG_INSTALL_SYNCTHING_LICENSE_FAILED="无法安装 Syncthing 许可证"
    MSG_INSTALL_SYNCTHING_AUTHORS_FAILED="无法安装 Syncthing AUTHORS 文件"

    MSG_GENERATE_CONFIG_FAILED="无法生成 Syncthing 配置"
    MSG_CONFIG_NOT_GENERATED="未生成 Syncthing config.xml"
    MSG_CONFIGURE_GUI_FAILED="无法配置 Syncthing Web UI 局域网访问"
    MSG_GUI_ADDRESS_UNKNOWN="无法确定 config.xml 中的 Syncthing Web UI 地址"

    MSG_DAEMON_RELOAD_FAILED="systemd daemon-reload 失败"
    MSG_ENABLE_SERVICE_FAILED="无法启用 RSM 服务"
    MSG_START_SERVICE_FAILED="无法启动 RSM 服务"
    MSG_SERVICE_START_FAILED="Syncthing 服务启动失败"
    MSG_NOT_INSTALLED="RSM 未安装。"

    MSG_VERSION="版本"
    MSG_CREATED_BY="作者"

else

    MSG_PRECHECK="Pre-check"
    MSG_INSTALLING="Installing"
    MSG_POSTCHECK="Post-check"

    MSG_ARCH="Architecture"
    MSG_TOOLS="Required system tools available"
    MSG_SYSTEMD="systemd user session available"
    MSG_PAYLOAD="Syncthing payload found"
    MSG_LICENSES="License and third-party notices found"

    MSG_EXISTING_RSM="An existing RSM installation was detected"
    MSG_PREVIOUS_CONFIG="Previous RSM configuration detected"
    MSG_NO_RSM="No existing RSM installation detected"

    MSG_RUNNING_SYNCTHING="A Syncthing process is already running"
    MSG_NO_SYNCTHING="No running Syncthing process detected"

    MSG_PORT_AVAILABLE="available"
    MSG_PORT_IN_USE="is already in use"

    MSG_DIRS_CREATED="Installation directories created"
    MSG_SYNCTHING_INSTALLED="Syncthing installed"
    MSG_NOTICES_INSTALLED="License and third-party notices installed"

    MSG_CONFIG_PRESERVED="Previous Syncthing configuration preserved"
    MSG_CONFIG_GENERATED="Syncthing configuration generated"
    MSG_GUI_ALREADY="Syncthing Web UI already configured for LAN access"
    MSG_GUI_CONFIGURED="Syncthing Web UI configured for LAN access"

    MSG_SERVICE_INSTALLED="systemd user service installed"
    MSG_SERVICE_RUNNING="Syncthing service is running"
    MSG_GUI_LISTENING="Syncthing Web UI is listening on TCP 8384"

    MSG_COMPLETED="Installation completed"
    MSG_RUNNING="Running"
    MSG_AUTOSTART="RSM will start automatically with your Steam Deck."

    MSG_UNSUPPORTED_ARCH="Unsupported architecture"
    MSG_X86_REQUIRED="x86_64 required"
    MSG_COMMAND_NOT_FOUND="Required command not found"
    MSG_SYSTEMD_UNAVAILABLE="systemd user session is not available"
    MSG_PAYLOAD_NOT_FOUND="Syncthing payload not found"
    MSG_PAYLOAD_NOT_EXECUTABLE="Syncthing payload is not executable"
    MSG_DIST_FILE_NOT_FOUND="Required distribution file not found"

    MSG_RSM_ALREADY_INSTALLED="An existing RSM installation was detected"
    MSG_SYNCTHING_ALREADY_RUNNING="A Syncthing process is already running"

    MSG_PORT_IN_USE="is already in use"
    MSG_PORT_NOT_DETECTED="TCP 8384 was not detected after startup"

    MSG_CREATE_INSTALL_DIR_FAILED="Could not create installation directory"
    MSG_CREATE_CONFIG_DIR_FAILED="Could not create configuration directory"
    MSG_CREATE_SYSTEMD_DIR_FAILED="Could not create systemd user directory"

    MSG_INSTALL_SYNCTHING_FAILED="Could not install Syncthing binary"
    MSG_CHMOD_SYNCTHING_FAILED="Could not set Syncthing executable permission"

    MSG_INSTALL_RSM_LICENSE_FAILED="Could not install RSM license"
    MSG_INSTALL_NOTICE_FAILED="Could not install third-party notices"
    MSG_INSTALL_SYNCTHING_LICENSE_FAILED="Could not install Syncthing license"
    MSG_INSTALL_SYNCTHING_AUTHORS_FAILED="Could not install Syncthing authors file"

    MSG_GENERATE_CONFIG_FAILED="Could not generate Syncthing configuration"
    MSG_CONFIG_NOT_GENERATED="Syncthing config.xml was not generated"
    MSG_CONFIGURE_GUI_FAILED="Could not configure Syncthing GUI for LAN access"
    MSG_GUI_ADDRESS_UNKNOWN="Could not determine Syncthing GUI address in config.xml"

    MSG_DAEMON_RELOAD_FAILED="systemd daemon-reload failed"
    MSG_ENABLE_SERVICE_FAILED="Could not enable RSM service"
    MSG_START_SERVICE_FAILED="Could not start RSM service"
    MSG_SERVICE_START_FAILED="Syncthing service failed to start"
    MSG_NOT_INSTALLED="RSM was not installed."

    MSG_VERSION="Version"
    MSG_CREATED_BY="Created by"

fi

fail() {
    echo
    echo "[FAIL] $1"
    echo
    echo "$MSG_NOT_INSTALLED"
    exit 1
}

ok() {
    echo "[ OK ] $1"
}

warn() {
    echo "[WARN] $1"
}

port_tcp_in_use() {
    ss -lnt 2>/dev/null | awk '{print $4}' | grep -qE "(^|:)$1$"
}

port_udp_in_use() {
    ss -lnu 2>/dev/null | awk '{print $5}' | grep -qE "(^|:)$1$"
}

echo
echo "========================================"
echo "  Retro Save Manager - Steam Deck"
echo "  $MSG_VERSION $RSM_VERSION"
echo
echo "  $MSG_CREATED_BY SimonBits"
echo "  YouTube: @SimonBitsDev"
echo "  Bilibili: 大叔怀旧研究所"
echo "========================================"
echo
echo "[$MSG_PRECHECK]"
echo

# ------------------------------------------------------------
# Architecture
# ------------------------------------------------------------

ARCH="$(uname -m)"

if [ "$ARCH" != "x86_64" ]; then
    fail "$MSG_UNSUPPORTED_ARCH: $ARCH ($MSG_X86_REQUIRED)"
fi

ok "$MSG_ARCH: $ARCH"

# ------------------------------------------------------------
# Required commands
# ------------------------------------------------------------

for cmd in systemctl ss awk grep sed pgrep ip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        fail "$MSG_COMMAND_NOT_FOUND: $cmd"
    fi
done

ok "$MSG_TOOLS"

# ------------------------------------------------------------
# systemd user session
# ------------------------------------------------------------

if ! systemctl --user show-environment >/dev/null 2>&1; then
    fail "$MSG_SYSTEMD_UNAVAILABLE"
fi

ok "$MSG_SYSTEMD"

# ------------------------------------------------------------
# Payload
# ------------------------------------------------------------

if [ ! -f "$PAYLOAD" ]; then
    fail "$MSG_PAYLOAD_NOT_FOUND: $PAYLOAD"
fi

if [ ! -x "$PAYLOAD" ]; then
    fail "$MSG_PAYLOAD_NOT_EXECUTABLE"
fi

ok "$MSG_PAYLOAD"

for file in \
    "$RSM_LICENSE" \
    "$THIRD_PARTY_NOTICE" \
    "$SYNCTHING_LICENSE" \
    "$SYNCTHING_AUTHORS"
do
    if [ ! -f "$file" ]; then
        fail "$MSG_DIST_FILE_NOT_FOUND: $file"
    fi
done

ok "$MSG_LICENSES"

# ------------------------------------------------------------
# Existing RSM installation
# ------------------------------------------------------------

EXISTING_CONFIG=false

if [ -f "$SERVICE_FILE" ] || [ -f "$SYNCTHING_BIN" ]; then
    fail "$MSG_RSM_ALREADY_INSTALLED"
fi

if [ -f "$CONFIG_DIR/config.xml" ]; then
    EXISTING_CONFIG=true
    ok "$MSG_PREVIOUS_CONFIG"
else
    ok "$MSG_NO_RSM"
fi

# ------------------------------------------------------------
# Existing Syncthing process
# ------------------------------------------------------------

if pgrep -x syncthing >/dev/null 2>&1; then
    fail "$MSG_SYNCTHING_ALREADY_RUNNING"
fi

ok "$MSG_NO_SYNCTHING"

# ------------------------------------------------------------
# Ports
# ------------------------------------------------------------

if port_tcp_in_use 8384; then
    fail "TCP 8384 $MSG_PORT_IN_USE"
fi

ok "TCP 8384 $MSG_PORT_AVAILABLE"

if port_tcp_in_use 22000; then
    warn "TCP 22000 $MSG_PORT_IN_USE"
else
    ok "TCP 22000 $MSG_PORT_AVAILABLE"
fi

if port_udp_in_use 22000; then
    warn "UDP 22000 $MSG_PORT_IN_USE"
else
    ok "UDP 22000 $MSG_PORT_AVAILABLE"
fi

if port_udp_in_use 21027; then
    warn "UDP 21027 $MSG_PORT_IN_USE"
else
    ok "UDP 21027 $MSG_PORT_AVAILABLE"
fi

echo
echo "[$MSG_INSTALLING]"
echo

# ------------------------------------------------------------
# Create directories
# ------------------------------------------------------------

mkdir -p "$BIN_DIR" || fail "$MSG_CREATE_INSTALL_DIR_FAILED"
mkdir -p "$CONFIG_DIR" || fail "$MSG_CREATE_CONFIG_DIR_FAILED"
mkdir -p "$SYSTEMD_DIR" || fail "$MSG_CREATE_SYSTEMD_DIR_FAILED"

ok "$MSG_DIRS_CREATED"

# ------------------------------------------------------------
# Install Syncthing
# ------------------------------------------------------------

cp "$PAYLOAD" "$SYNCTHING_BIN" || fail "$MSG_INSTALL_SYNCTHING_FAILED"
chmod +x "$SYNCTHING_BIN" \
    || fail "$MSG_CHMOD_SYNCTHING_FAILED"

ok "$MSG_SYNCTHING_INSTALLED"

# ------------------------------------------------------------
# Install license and third-party notices
# ------------------------------------------------------------

cp "$RSM_LICENSE" "$INSTALL_DIR/LICENSE" \
    || fail "$MSG_INSTALL_RSM_LICENSE_FAILED"

cp "$THIRD_PARTY_NOTICE" "$INSTALL_DIR/THIRD_PARTY_NOTICES.md" \
    || fail "$MSG_INSTALL_NOTICE_FAILED"

cp "$SYNCTHING_LICENSE" "$INSTALL_DIR/SYNCTHING-LICENSE.txt" \
    || fail "$MSG_INSTALL_SYNCTHING_LICENSE_FAILED"

cp "$SYNCTHING_AUTHORS" "$INSTALL_DIR/SYNCTHING-AUTHORS.txt" \
    || fail "$MSG_INSTALL_SYNCTHING_AUTHORS_FAILED"

ok "$MSG_NOTICES_INSTALLED"

# ------------------------------------------------------------
# Generate initial Syncthing configuration
# ------------------------------------------------------------

CONFIG_XML="$CONFIG_DIR/config.xml"

if [ "$EXISTING_CONFIG" = true ]; then

    ok "$MSG_CONFIG_PRESERVED"

else

    "$SYNCTHING_BIN" generate --home="$CONFIG_DIR" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        fail "$MSG_GENERATE_CONFIG_FAILED"
    fi

    if [ ! -f "$CONFIG_XML" ]; then
        fail "$MSG_CONFIG_NOT_GENERATED"
    fi

    ok "$MSG_CONFIG_GENERATED"

fi

# ------------------------------------------------------------
# Allow LAN access to Syncthing GUI
# ------------------------------------------------------------

if grep -q '<address>0\.0\.0\.0:8384</address>' "$CONFIG_XML"; then

    ok "$MSG_GUI_ALREADY"

elif grep -q '<address>127\.0\.0\.1:8384</address>' "$CONFIG_XML"; then

    sed -i \
        's#<address>127\.0\.0\.1:8384</address>#<address>0.0.0.0:8384</address>#' \
        "$CONFIG_XML"

    if ! grep -q '<address>0\.0\.0\.0:8384</address>' "$CONFIG_XML"; then
        fail "$MSG_CONFIGURE_GUI_FAILED"
    fi

    ok "$MSG_GUI_CONFIGURED"

else

    fail "$MSG_GUI_ADDRESS_UNKNOWN"

fi

# ------------------------------------------------------------
# Install systemd user service
# ------------------------------------------------------------

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Retro Save Manager - Syncthing
After=network-online.target

[Service]
Type=simple
ExecStart=$SYNCTHING_BIN --home=$CONFIG_DIR
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

ok "$MSG_SERVICE_INSTALLED"

# ------------------------------------------------------------
# Enable and start service
# ------------------------------------------------------------

systemctl --user daemon-reload || fail "$MSG_DAEMON_RELOAD_FAILED"

systemctl --user enable "$SERVICE_NAME" >/dev/null 2>&1 \
    || fail "$MSG_ENABLE_SERVICE_FAILED"

systemctl --user start "$SERVICE_NAME" \
    || fail "$MSG_START_SERVICE_FAILED"

sleep 2

# ------------------------------------------------------------
# Post-check
# ------------------------------------------------------------

echo
echo "[$MSG_POSTCHECK]"
echo

if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    ok "$MSG_SERVICE_RUNNING"
else
    echo
    systemctl --user status "$SERVICE_NAME" --no-pager
    fail "$MSG_SERVICE_START_FAILED"
fi

if ss -lnt 2>/dev/null | grep -q ':8384 '; then
    ok "$MSG_GUI_LISTENING"
else
    warn "$MSG_PORT_NOT_DETECTED"
fi

# ------------------------------------------------------------
# Find LAN IP
# ------------------------------------------------------------

LAN_IP="$(ip -4 route get 1.1.1.1 2>/dev/null \
    | awk '{for (i=1; i<=NF; i++) if ($i=="src") {print $(i+1); exit}}')"

echo
echo "========================================"
echo "  $MSG_COMPLETED"
echo "========================================"
echo
echo "Syncthing: $MSG_RUNNING"

if [ -n "$LAN_IP" ]; then
    echo "Web UI:    http://$LAN_IP:8384"
else
    echo "Web UI:    http://<Steam-Deck-IP>:8384"
fi

echo
echo "$MSG_AUTOSTART"
echo
