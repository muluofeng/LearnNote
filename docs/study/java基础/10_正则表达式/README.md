### 正则表达式



#### 1. 语法

```
0. 元字符
    \d	匹配一个数字，是 [0-9] 的简写
    \D	匹配一个非数字，是 [^0-9] 的简写
    \s	匹配一个空格，是 [ \t\n\x0b\r\f] 的简写
    \S	匹配一个非空格
    \w	匹配一个单词字符（大小写字母、数字、下划线），是 [a-zA-Z_0-9] 的简写
    \W	匹配一个非单词字符（除了大小写字母、数字、下划线之外的字符），等同于 [^\w]
1. 限定符
    *	    匹配 >=0 个，是 {0,} 的简写	X* 表示匹配零个或多个字母 X，.* 表示匹配任何字符串
    +	    匹配 >=1 个，是 {1,} 的简写	X+ 表示匹配一个或多个字母 X
    ?	    匹配 1 个或 0 个，是 {0,1} 的简写	X? 表示匹配 0 个或 1 个字母 X
    {X}	    只匹配 X 个字符	\d{3} 表示匹配 3 个数字，.{10} 表示匹配任何长度是 10 的字符串
    {X,Y}	匹配 >=X 且 <=Y 个	\d{1,4} 表示匹配至少 1 个最多 4 个数字
    *?	    如果?是限定符 * 或 + 或 ? 或 {} 后面的第一个字符，那么表示非贪婪模式（尽可能少的匹配字符），而不是默认的贪婪模式
 2. 字符匹配符
   []    可接收的字符列表      [abc]  表示abc中任意一个字符
   [^]   不可接收的字符列表    [^abc] 表示除了abc中任意一个字符
   -     连字符               [a-z] 任意的小写字母
   .     匹配除了 \n 以外的字符  a..b   a开头b结尾的4个长度的字符串
   \\d   匹配单个数字字符       \\d{3}
   x|y   匹配x或者y
   ^     指定起始字符           =
   $     指定结束字符
3. 捕获组
    普通捕获组
             (\\d{4})-((\\d{2})-(\\d{2}))  正则表达式左侧开始，每出现一个左括号"("记做一个分组，分组编号从 1 开始。0 代表整个表达式
    命名捕获组
              (?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})   每个以左括号开始的捕获组，都紧跟着 ?，而后才是正则表达式。
```





#### 分组或者子表达式

是把多个字符当一个单独单元进行处理的方法，它通过对括号内的字符分组来创建

- 捕获分组

```java
  			//4个分组 
				//第一个 ((\\d{4})-(\\d{2})-(\\d{2})) 
				//第二个 (\\d{4}) 
				//第三(\\d{2}) 
				//第四 (\\d{2})
				Pattern compile = Pattern.compile("((\\d{4})-(\\d{2})-(\\d{2}))");
        Matcher matcher = compile.matcher("2012-12-09");
				System.out.println(matcher.groupCount());  //4个分组 还有一个特殊的组（group(0)），它总是代表整个表达式。该组不包括在 groupCount 的返回值中
        while (matcher.find()) {
            String group = matcher.group();
            String group0 = matcher.group(0);
            String group1 = matcher.group(1);
            String group2 = matcher.group(2);
            String group3 = matcher.group(3);
            String group4 = matcher.group(4);
            System.out.println(group);   //2012-12-09
            System.out.println(group0);  //2012-12-09
            System.out.println(group1);  //2012-12-09
            System.out.println(group2);  //2012
            System.out.println(group3);  //12
            System.out.println(group4);  //09
        }
```

- 命名分组

  ```java
  System.out.println("=======命名分组=======");
          Pattern compile = Pattern.compile("(?<year>\\d{4})-(?<month>\\d{2})-(?<date>\\d{2})");
          Matcher matcher = compile.matcher("2012-12-09");
  
          while (matcher.find()) {
              String group0 = matcher.group(0);
              String group1 = matcher.group("year");
              String group2 = matcher.group("month");
              String group3 = matcher.group("date");
              System.out.println(group0);
              System.out.println(group1);
              System.out.println(group2);
              System.out.println(group3);
          }
  ```

  