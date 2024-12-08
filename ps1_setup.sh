#!/bin/bash

# 检查当前解释器
if [[ "$SHELL" == *"zsh"* ]]; then
    echo "当前解释器是 zsh，准备切换到 bash..."
    
    # 查找 bash 路径
    BASH_PATH=$(which bash)
    if [[ -z "$BASH_PATH" ]]; then
        echo "无法找到 bash，请确保已安装 bash 后重试。"
        exit 1
    fi
    
    echo "bash 路径：$BASH_PATH"
    
    # 检查 chsh 是否有权限执行
    if ! chsh -s "$BASH_PATH" 2>/dev/null; then
        echo "无法执行 chsh 命令。您可以尝试以下两种方式："
        echo "1. 使用 sudo 运行：sudo chsh -s \"$BASH_PATH\""
        echo "2. 手动修改 /etc/passwd 文件，将您的默认 shell 改为 $BASH_PATH"
        exit 1
    fi
    
    echo "已将默认解释器切换为 bash。请重新登录以使更改生效。"
else
    echo "当前解释器已是 bash，无需切换。"
fi

# 定义 PS1 配置
PS1_CONFIG='export PS1="\[\033]2;\h:\u \w\007\033[33;1m\]\u \033[35;1m\t\033[0m \[\033[36;1m\]\w\[\033[0m\]\n\[\e[32;1m\]$ \[\e[0m\]"'

# 选择配置文件
if [[ -f "$HOME/.bash_profile" ]]; then
    CONFIG_FILE="$HOME/.bash_profile"
elif [[ -f "$HOME/.bashrc" ]]; then
    CONFIG_FILE="$HOME/.bashrc"
else
    CONFIG_FILE="$HOME/.bash_profile"
    touch "$CONFIG_FILE"
    echo "创建新的配置文件：$CONFIG_FILE"
fi

# 检查并移除已有 PS1 配置
if grep -q 'export PS1=' "$CONFIG_FILE"; then
    echo "检测到已有 PS1 配置，正在移除..."
    sed -i '/export PS1=/d' "$CONFIG_FILE"
fi

# 添加新的 PS1 配置
echo "$PS1_CONFIG" >> "$CONFIG_FILE"
echo "已将新的 PS1 配置添加到 $CONFIG_FILE。"

# 重新加载配置文件
echo "重新加载配置文件..."
source "$CONFIG_FILE"

# 提示用户检查 shell
echo "切换完成，请运行以下命令确认当前 shell："
echo "echo \$SHELL"

