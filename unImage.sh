#/usr/local/bash4.2/bin/bash

#shell脚本操作：http://c.biancheng.net/view/1120.html

# find命令查找文件包含内容
PROJ=`find . -name '*.xib' -o -name '*.[mh]' -o -name '*.storyboard' -o -name '*.mm'`

for png in `find . -name '*.png'`
do
   name=`basename -s .png $png`
   name=`basename -s @2x $name`
   if ! grep -qhs "$name" "$PROJ"; then
        echo "$png"
   fi
done
