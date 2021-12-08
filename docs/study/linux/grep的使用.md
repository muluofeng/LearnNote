
grep的使用方法

基本使用方法grep是一种使用正则表达式的多用途文本搜索工具。

通常的使用结构如：

```
grep 'test' testfile.txt
假设testfile.txt中的内容为：

te
test
testaaa
aatestbb
输出为：

./testfile.txt:test
./testfile.txt:testaa
./testfile.txt:aatestbb

```
其中'test'为要匹配的正则表达式，testfile.txt为要搜索的文件。

若没有指定文件，grep也可以在管道中对stdout进行处理

```

ls | grep 'test'
输出是：

testfile.txt

```
###  grep的常用参数
#### -i 在搜索的时候忽略大小写


例如文件夹中有两个文件testfile.txt和TestFile.txt。

运行如下脚本：
```

echo 'first one'
ls | grep 'test'
echo 'second one'
ls | grep -i 'test'
将输出：

first one
testfile.txt
second one
testfile.txt
TestFile.txt
```

####  -w 匹配整词

即如果执行

grep -w 'test' testfile.txt
将会匹配test不会匹配testaa

####   -l 仅列出符合匹配的文件，而不列出匹配的具体行

例如：
```
grep -l 'test' testfile.txt
输出为：

./testfile.txt

```
####  -L
列出不匹配的文件名，与-l正好相反。

####  -r
不仅匹配当前目录，还匹配其子目录

-r选项在很多命令中都有涉及，这里就不赘述了。

####  -n
列出行并显示行号

即按照上述的文件，执行命令

grep -n 'test' testfile.txt
得到的输出会是：

2:test
3:testaaa
4:aatestbb
-v(--invert-match)
显示所有不匹配的行

顾名思义

-c(--count)
显示匹配到的行数，而不会列出具体的匹配

所以执行：

grep -c 'test' testfile.txt
会得到

./testfile.txt:2
-E或者使用egrep(mac中没有)
使用扩展的正则表达式。

grep只会使用基本的正则表达式。因此我们需要-E选项来对正则表达式进行扩展。

例如上述文件，可以执行：

grep -E 'testa|testb' testfile.txt
来匹配：

./testfile.txt:testaaa
./testfile.txt:aatestbb
其中或(|)是扩展的正则表达式中的内容。

-F
快速的grep，只按照字符串字面上的意思进行搜索。不允许使用正则表达式。有时候这会更加方便

-h
不显示匹配的文件名

-s
静默执行。只输出错误信息，不输出其他信息。

####  -An 在匹配行打印完毕后再打印n行

例如执行：

grep -A1 'testa' testfile.txt
输出：

./testfile.txt:testaaa
./testfile.txt:aatestbb
####  -Bn 在匹配行前打印n行

执行：

grep -B1 'testa' testfile.txt
输出：

./testfile.txt:test
./testfile.txt:testaaa
-Cz
在前后各自打印z行。

例如：

grep -C1 'testa' testfile.txt
输出为:

./testfile.txt:test
./testfile.txt:testaaa
./testfile.txt:aatestbb
-b
在每一行前面打印字符的偏移量

-f
-f file从文件file中提取模板。空文件包含0个模板。

例如我们可以新建一个patternfile文件用于储存模板。

内容为：

test
testa
执行：

grep -f patternfile testfile.txt
匹配结果为：

./testfile.txt:test
./testfile.txt:testaa
./testfile.txt:aatestbb
-x
只打印整行匹配的行


