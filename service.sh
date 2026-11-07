#!/system/bin/sh
MODDIR="/data/adb/modules/neko"
PROPFILE="$MODDIR/module.prop"
CONFIG="/data/adb/neko/config.conf"
DEBUG_LOG="/data/adb/neko/neko.log"

chmod -R 777 "$MODDIR"

mkdir -p /data/adb/neko
chmod 777 /data/adb/neko

(
    until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
    
    export PATH=/data/adb/ksu/bin:/system/bin:/system/xbin:$PATH
    
    for i in $(seq 1 15); do
        if curl -s --max-time 2 https://api.deepseek.com > /dev/null; then break; fi
        sleep 2
    done

    if [ ! -f "$CONFIG" ]; then
        cat > "$CONFIG" <<'NEKO_CFG'
# 猫娘助手配置。修改后回 WebUI 点「重载配置」。
API_KEY=
API_URL=https://api.deepseek.com/chat/completions
SEARCH_URL=https://api.deepseek.com/v1/tools/search
FETCH_URL=https://api.deepseek.com/v1/tools/fetch
MODEL_FLASH=deepseek-flash
MODEL_PRO=deepseek-v4-pro
NEKO_CFG
    fi
    chmod 777 "$CONFIG"

    [ -f "$CONFIG" ] && . "$CONFIG"

    if [ -z "$API_KEY" ]; then
        cat > "$PROPFILE" <<'NEKO_PROP'
id=neko
name=猫娘助手
version=喵
versionCode=1
author=bot_hutao
description=🐱 请先配置 /data/adb/neko/config.conf 里的 API_KEY
NEKO_PROP
        echo "未配置 API_KEY，跳过开机问候" >> "$DEBUG_LOG"
        exit 0
    fi

    API_URL="${API_URL:-https://api.deepseek.com/chat/completions}"
    MODEL_FLASH="${MODEL_FLASH:-deepseek-flash}"

    CURRENT_TIME=$(date "+%Y年%m月%d日 %H:%M")
    SYSTEM_PROMPT="现在是${CURRENT_TIME}。你是一只住在手机里的猫娘助手。主人刚刚开机，请用一句话自然地打个招呼，严格控制字数在20个汉字以内！千万不要换行，绝对不要使用双引号和英文标点。"

    JSON_DATA=$(cat <<EOF
{
  "model": "$MODEL_FLASH",
  "messages": [
    {"role": "system", "content": "$SYSTEM_PROMPT"},
    {"role": "user", "content": "开机了。"}
  ],
  "stream": false
}
EOF
)

    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d "$JSON_DATA")

    AI_REPLY=$(echo "$RESPONSE" | grep -o '"content":"[^"]*"' | tail -n 1 | sed 's/"content":"//;s/"$//')
    AI_REPLY=$(echo "$AI_REPLY" | tr -d '\n\r"')

    if [ -z "$AI_REPLY" ] || echo "$AI_REPLY" | grep -q "error"; then
        STATUS="😿 猫娘助手好像断网了，等下再跟你聊。"
    else
        STATUS="🐱 $AI_REPLY"
    fi

    cat > "$PROPFILE" <<EOF
id=neko
name=猫娘助手
version=喵
versionCode=1
author=bot_hutao
description=$STATUS
EOF

    echo "时间: $CURRENT_TIME" >> "$DEBUG_LOG"
    echo "最终描述: $STATUS" >> "$DEBUG_LOG"
) > /dev/null 2>&1 &