#/usr/local/bash4.2/bin/bash

#shell脚本操作：http://c.biancheng.net/view/1120.html

input_filename='/Users/dafyit/Desktop/DetectTool-LinkMap--.txt'
output_filename='/Users/dafyit/Desktop/output.txt'


##内存大小转换 shell只能返回整数
#getSize(){
#    echo "第一个参数为 $1 !"
#    size=$1
#    if [[ $size > 1073741824 ]]
#    then
#        size=$(($size/1073741824))
#        return "${size}g"
#
#    elif [[ $size > 1048576 ]]
#    then
#        size=$(($size/1048576))
#        return "${size}m"
#
#    elif [[ $size > 1024 ]]
#    then
#        size=$(($size/1024))
#        return "${size}k"
#
#    elif [[ $size > 0 ]]
#    then
#        return "${size}b"
#    fi
#}


#统计字典(bash版本>=4.0,才会有字典的声明)
declare -A dict
declare -A dictSize

echo "***********************************"

#dict["a"]="fdf"
#dict["b"]="dsf"
#
##打印指定key的value
#echo ${dict["b"]}
##打印所有key值
#echo ${!dict[*]}
##打印所有value
#echo ${dict[*]}

echo "***********************************"

#可执行文件
objStart="0" #0: 未开始 1：开始 2：结束
keyObjStr='# Object files:'
#数据存储区域
keySectionStr='# Sections:'
#符号表
symbolStart="0" #0: 未开始 1：开始 2：结束
keySymbolStr='# Symbols:'
#Dead Stripped Symbols
keyDeadSymbolStr='# Dead Stripped Symbols:'



#记录偏移
objectOffset=0
symbolOffset=0

#行读取文件信息
while read LINE
do
#输出行
#echo $LINE

objResult=$(echo $LINE | grep "${keyObjStr}")
sectionResult=$(echo $LINE | grep "${keySectionStr}")
symbolResult=$(echo $LINE | grep "${keySymbolStr}")
deadSymbolResult=$(echo $LINE | grep "${keyDeadSymbolStr}")

if [[ "$objResult" != "" ]]
then
    objStart="1"
    objectOffset=0
elif [[ "$sectionResult" != "" ]]
then
    objStart="2"
elif [[ "$symbolResult" != "" ]]
then
    symbolStart="1"
    symbolOffset=0
elif [[ "$deadSymbolResult" != "" ]]
then
    symbolStart="2"
fi

#获取文件map
objectOffset=$(($objectOffset+1))
if [[ $objStart == "1" ]] && [[ $objectOffset > 1 ]]
then
exKey="${LINE%%]*}]"
#echo $exKey
sprValue=${LINE#*]}
exValue=${sprValue##*/}
#echo $exValue

#shell在处理空格的时候会进行换行
reExValue=`echo $exValue | sed 's/ /_/g'`
dict[$exKey]=$reExValue
dictSize[$reExValue]=0

fi

#获取符号表数据
symbolOffset=$(($symbolOffset+1))
if [[ $symbolStart == "1" ]] && [[ $symbolOffset > 2 ]]
then
reSeparateStr="${LINE%%]*}]"
size=${reSeparateStr: 14: 9} #size
key=${reSeparateStr: 23} #key

sizeValue=`echo $((16#${size}))`  #16进制转换为10进制

sizeKey=${dict[$key]}
#echo $key
#echo $sizeKey

totalSize=${dictSize[$sizeKey]}
totalSize=$(($totalSize+$sizeValue))
dictSize[$sizeKey]=$totalSize

fi

done <$input_filename

echo "=======================输出文件size========================"


for key in ${!dictSize[*]}
do

#    echo $key
#    size=`getSize ${dictSize[$key]}`

    size=${dictSize[$key]}
    if [ $size -gt 1073741824 ]
    then
        size=$(($size/1073741824))
        echo "$key : ${size}g" >>$output_filename

    elif [ $size -gt 1048576 ]
    then
        size=$(($size/1048576))
        echo "$key : ${size}m" >>$output_filename

    elif [ $size -gt 1024 ]
    then
        size=$(($size/1024))
        echo "$key : ${size}k" >>$output_filename

    elif [ $size -gt 0 ]
    then
        echo "$key : ${size}b" >>$output_filename
    fi

done

echo "=========================================================="

