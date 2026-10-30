#!/system/bin/sh
MODDIR="/data/adb/modules/neko"
CONFIG="/data/adb/neko/config.conf"
CMD_FILE="$MODDIR/neko_cmd.txt"
RES_FILE="$MODDIR/neko_res.txt"
TS_FILE="$MODDIR/neko_last_exec.txt"

chmod -R 777 "$MODDIR"

# 建立持久化数据目录
mkdir -p /data/adb/neko
chmod 777 /data/adb/neko

# 迁移旧配置
if [ -f "$MODDIR/config.conf" ]; then
    mv "$MODDIR/config.conf" "$CONFIG"
fi

# config 只纠正权限
[ -f "$CONFIG" ] && chmod 777 "$CONFIG" 2>/dev/null

# === 核心改动：将 KSU 的 BusyBox 置顶 ===
export PATH=/data/adb/ksu/bin:/system/bin:/system/xbin:$PATH

if [ -f "$CMD_FILE" ]; then
    CMD=$(cat "$CMD_FILE")
    echo "🐱 猫娘正在执行: $CMD"
    
    OLD_SE=$(getenforce 2>/dev/null)
    if [ "$OLD_SE" = "Enforcing" ]; then
        setenforce 0 2>/dev/null
    fi
    
    timeout 15 sh -c "$CMD" > "$RES_FILE" 2>&1
    EXIT_CODE=$?
    
    if [ "$OLD_SE" = "Enforcing" ]; then
        setenforce 1 2>/dev/null
    fi

    if [ "$EXIT_CODE" -eq 124 ]; then
        echo "___TIMEOUT___" >> "$RES_FILE"
    else
        echo "___EOF___" >> "$RES_FILE"
    fi
    
    date +%s > "$TS_FILE"

    chmod 777 "$RES_FILE" "$TS_FILE"
    rm -f "$CMD_FILE"
    echo "✅ 执行完毕！请回 WebUI 读取。"
else
    echo "⚠️ 没有待执行的命令。"
fi