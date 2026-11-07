#!/system/bin/sh
export PATH=/data/adb/modules/neko/bin:/data/adb/ksu/bin:/system/bin:/system/xbin:$PATH
export TESSDATA_PREFIX=/data/adb/modules/neko/tessdata
DIR="/data/adb/neko"

IMG_PATH="$DIR/screen.png"
TSV_PATH="$DIR/ocr_out.tsv"
RES_PATH="$DIR/ocr_res.txt"

# 截图
screencap -p "$IMG_PATH"

# 识别
tesseract "$IMG_PATH" "${TSV_PATH%.tsv}" -l chi_sim+eng -c tessedit_create_tsv=1 -c user_defined_dpi=300 >/dev/null 2>&1

# 清理可能残留的结果文件
> "$RES_PATH"

# 提取并按行合并
awk 'BEGIN {FS="\t"} 
NR>1 && $1==5 && $11>30 && $12!="" { 
  id=$2"_"$3"_"$4"_"$5; 
  if(!(id in minx)) { minx[id]=$7; miny[id]=$8; maxx[id]=$7+$9; maxy[id]=$8+$10; text[id]=$12; } 
  else { 
    if($7<minx[id]) minx[id]=$7; 
    if($8<miny[id]) miny[id]=$8; 
    if($7+$9>maxx[id]) maxx[id]=$7+$9; 
    if($8+$10>maxy[id]) maxy[id]=$8+$10; 
    text[id]=text[id]$12; 
  } 
} 
END { 
  for(i in text) { 
    cx=int((minx[i]+maxx[i])/2); cy=int((miny[i]+maxy[i])/2); 
    print text[i]" (点击坐标: "cx", "cy")"; 
  } 
}' "$TSV_PATH" >> "$RES_PATH"

echo "___EOF___" >> "$RES_PATH"