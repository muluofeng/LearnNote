#!/bin/bash
function printDir(){
     for element in `ls -1 $1 | sort -V`
     do
        dir_or_file=$1"/"$element
        # / 的数量
        dircounter=`echo $dir_or_file | grep -o / | wc -l`
        rootCount=`echo $root | grep -o / | wc -l`
        counter=`expr $dircounter - $rootCount`
        let length=${#root}

        path=${dir_or_file:$length}

         ## 判断字符串是否存在排除的数组中
        if [[ "${exclude[@]}"  =~ $element ]]; then
            continue
        fi



        # 是目录
        if [ -d $dir_or_file ]
        then
            fileCount=`ls -1 $dir_or_file/ | wc -l`
            imagesCount=`ls -1 $dir_or_file/ | grep -o images| wc -l`
            readmeCount=`ls -1 $dir_or_file/ | grep -o README| wc -l`
    
            # if [ [ $fileCount -eq 2 ] && [$imagesCount -eq 1 ] && [$readmeCount -eq 1 ]] || [[ $fileCount -eq 1 ] && [$readmeCount -eq 1 ]]
            if [ $fileCount -eq 2 ] || [ $fileCount -eq 1 ] 
            then
                if  [ $imagesCount -eq 1 ] && [ $readmeCount -eq 1 ]
                then
                    printf '%0.s  ' $(seq 0 $counter)>>$targetMd 
                    echo  "* [$element](/study$path/README)">>$targetMd
                    continue
                fi    
                if  [ $fileCount -eq 1 ] && [ $readmeCount -eq 1 ]
                then
                    printf '%0.s  ' $(seq 0 $counter)>>$targetMd 
                    echo  "* [$element](/study$path/README)">>$targetMd
                    continue
                fi    

                if  [ $fileCount -eq 1 ] && [ $readmeCount -ne 1 ]
                then
                    printf '%0.s  ' $(seq 0 $counter)>>$targetMd 
                    echo  "* [$element]">>$targetMd
                    printDir $dir_or_file
                fi    
            else
                if [ $element = "images" ]
                then 
                continue  
                else   
                    printf '%0.s  ' $(seq 0 $counter)>>$targetMd 
                    echo  "* [$element]">>$targetMd
                    printDir $dir_or_file
                fi
            fi
        else
            # 是文件
            dirfileCount=`ls -1 $l/ | wc -l`
            # echo "$element---$dirfileCount"
            if [ $element = "README.md" ] && [ $dirfileCount -gt 2 ]
            then
                # echo $dirfileCount
                continue
            else
                printf '%0.s  ' $(seq 0 $counter)>>$targetMd 
                echo  "* [$element](/study$path)">>$targetMd
            fi    
        fi
     done
}

root="/Users/muluofeng/Documents/muluofeng.github.io/docs/study"
targetMd="/Users/muluofeng/Documents/muluofeng.github.io/docs/_sidebar.md"

exclude=(Code _media _sidebar.md _coverpage.md _navbar.md guide.md index.html 尚硅谷redis.mmap 黑马程序员-Redis学习笔记.doc)

cd ./study
cat /dev/null>$targetMd
echo "* 目录">>$targetMd
for file in $(ls ./ | sort -V )
do
    # 是目录
    if [ -d "$root/$file" ]
    then
          echo "    * [**$file**]">>$targetMd
           printDir $root/$file

    else
    # 是文件
        continue
    fi
done    

# readme 修改
targetREADMEMd="/Users/muluofeng/Documents/muluofeng.github.io/docs/README.md"
cat /dev/null>$targetREADMEMd
echo "# 学习笔记">>$targetREADMEMd
echo "* 首页">>$targetREADMEMd

for file in $(ls ./ | sort -V )
do
    # 是目录
    if [ -d "$root/$file" ]
    then
          echo "    * [**$file**]()">>$targetREADMEMd
    fi
done    

echo "###### 敖丙github https://github.com/AobingJava/JavaFamily">>$targetREADMEMd
echo "###### 互联网 Java 工程师进阶知识完全扫盲https://github.com/doocs/advanced-java">>$targetREADMEMd
echo "###### CS-Notes https://github.com/CyC2018/CS-Notes">>$targetREADMEMd
