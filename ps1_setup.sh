#!/bin/bash

# 检测平台
OS_TYPE="$(uname -s)"

# 检查当前解释器是否是 bash
if [[ "$SHELL" != *"bash"* ]]; then
    echo "当前解释器不是 bash，准备切换到 bash..."

    BASH_PATH=$(which bash)
    if [[ -z "$BASH_PATH" ]]; then
        echo "无法找到 bash，请安装后重试。"
        exit 1
    fi

    if ! chsh -s "$BASH_PATH" 2>/dev/null; then
        echo "无法切换 shell。请尝试使用："
        echo "sudo chsh -s \"$BASH_PATH\" $USER"
        echo "或手动编辑 /etc/passwd 修改默认 shell"
        exit 1
    fi
    echo "已将默认解释器切换为 bash，请重新登录终端以生效。"
    # 如果当前不是bash，不建议继续配置PS1，等下次登录后再来执行或在新会话中执行
    exit 0
fi

# 根据 OS 选择配置文件
if [[ "$OS_TYPE" == "Darwin" ]]; then
    CONFIG_FILE="$HOME/.bash_profile"
else
    CONFIG_FILE="$HOME/.bashrc"
fi
[[ ! -f "$CONFIG_FILE" ]] && touch "$CONFIG_FILE"

# 定义PS1配置
PS1_CONFIG='export PS1="\[\033]2;\h:\u \w\007\033[33;1m\]\u \033[35;1m\t\033[0m \[\033[36;1m\]\w\[\033[0m\]\n\[\e[32;1m\]$ \[\e[0m\]"'

# 备份
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# 移除已有PS1配置
if grep -q 'export PS1=' "$CONFIG_FILE"; then
    echo "检测到已有 PS1 配置，正在移除..."
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        sed -i '' '/export PS1=/d' "$CONFIG_FILE"
    else
        sed -i '/export PS1=/d' "$CONFIG_FILE"
    fi
fi

# 添加新的PS1配置
echo "$PS1_CONFIG" >> "$CONFIG_FILE"
echo "已将新的 PS1 配置添加到 $CONFIG_FILE。"

# 尝试重新加载配置文件
echo "重新加载配置文件..."
source "$CONFIG_FILE"

echo "关闭当前窗口重新开一个新的，配置就完成啦~"
