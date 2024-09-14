#### Stirng.intern() 方法



- 直接使用双引号声明出来的`String`对象会直接存储在常量池中。 比如 String  a ="11";
- 而 new 出来的 String 对象是放在 JAVA Heap 区域  比如 String  a = new String("11");    同时 如果常量池不存在 ”11“也会在  常量池  写入 11
- intern 方法 返回 Java查找常量池中是否有相同Unicode的字符串常量，如果有，则返回其的引用，如果没有，则在常量池中增加一个Unicode等于str的字符串并返回 原来字符串的引用

1. 当new  Stirng("a");会创建2个对象，一个在常量池的a,一个是堆里面的a,当然如果 常量池中有“a” 了那么常量池中就不需要创建了
3.String的equals方法进行了类型判断

```java
String s1 = "abc";
StringBuffer s2 = new StringBuffer(s1);
System.out.println(s1.equals(s2));   //false
```

2. String的intern()方法

当intern()方法被调用，如果字符串池中含有一个字符串和当前调用方法的字符串eqauls相等，那么就会返回池中的字符串。如果池中没有的话，则首先将当前字符串加入到池中，然后返回引用。

```java
    String s1 = "abc";
    String s2 = new String("abc");
    System.out.println(s1 ==s2.intern());  //true
```




demo 

```java
String s1 = "Programming";
String s2 = new String("Programming");
String s3 = "Program";
String s4 = "ming";
String s5 = "Program" + "ming";
String s6 = s3 + s4;
System.out.println(s1 == s2);         //false  s1指向常量池中变量，s2指向堆内存中的对象
System.out.println(s1 == s5);         //true  由于Program和ming都是常量，编译时，第二句会被自动编译为‘String s5 = "Programming";
System.out.println(s1 == s6);         
//false  创建一个以s3为基础的一个StringBuilder对象，然后调用StringBuilder的append()方法完成与s4的合并
//之后会调用toString()方法在堆（heap）中创建一个String对象，并把这个String对象的引用赋给s6

System.out.println(s1 == s6.intern());//true s6.intern() 指向常量池中的“Programming”
System.out.println(s2 == s2.intern());//false
```
