#!/system/bin/sh
export PATH=/data/adb/ksu/bin:/system/bin:/system/xbin:$PATH
DIR="/data/adb/neko"
XML_FILE="$DIR/ui.xml"
RES_FILE="$DIR/ui_res.txt"

# 抓取 UI 树
uiautomator dump "$XML_FILE" >/dev/null 2>&1

if [ ! -s "$XML_FILE" ]; then
    echo "当前 UI 树读取失败或为空。" > "$RES_FILE"
    echo "___EOF___" >> "$RES_FILE"
    exit 0
fi

# 清空结果文件
> "$RES_FILE"

# 解析 XML 并生成节点信息
sed 's/></>\n</g' "$XML_FILE" | grep '<node' | awk '{
    text=""; desc=""; cls=""; b=""; clk="";
    if (match($0, /text="[^"]*"/)) { text = substr($0, RSTART+6, RLENGTH-7); }
    if (match($0, /content-desc="[^"]*"/)) { desc = substr($0, RSTART+14, RLENGTH-15); }
    if (match($0, /class="[^"]*"/)) { cls = substr($0, RSTART+7, RLENGTH-8); }
    if (match($0, /clickable="[^"]*"/)) { clk = substr($0, RSTART+11, RLENGTH-12); }
    if (match($0, /bounds="[^"]*"/)) { b = substr($0, RSTART+8, RLENGTH-9); }
    
    if (text == "" && desc == "") { next; }
    if (text == "") { text = desc; }
    
    if (b != "") {
        split(b, arr, "[\\[\\],]");
        x1=arr[2]; y1=arr[3]; x2=arr[6]; y2=arr[7];
        cx=int((x1+x2)/2); cy=int((y1+y2)/2);
    } else {
        cx=0; cy=0;
    }
    
    n=split(cls, c_arr, ".");
    short_cls=c_arr[n];
    
    print "[" short_cls "] \"" text "\" (可点击=" clk ", 坐标=" cx "," cy ")"
}' >> "$RES_FILE"

echo "___EOF___" >> "$RES_FILE"