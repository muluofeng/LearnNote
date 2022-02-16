# 等等与equals的区别

## 前言

我们都知道， == 是比较内存地址，equals是比较值

但是这种非常错误的一种观点

- ==：比较基本数据类型的时候，比较的是值，引用数据类型比较的是地址（new的对象，==比较永远是false）
- equals：属于Object类的方法，如果我们没有重写过equals方法，那么它就是 ==，但是字符串里面的equals被重写过了，比较的是值

## 代码一

```
/**
 * equals和等等的区别
 *
 * @author: 陌溪
 * @create: 2020-04-03-8:50
 */
public class EqualsDemo {

    static class Person {
        private String name;

        public Person(String name) {
            this.name = name;
        }
    }
    public static void main(String[] args) {
        String s1 = new String("abc");
        String s2 = new String("abc");

        System.out.println(s1 == s2);
        System.out.println(s1.equals(s2));
        Set<String> set1 = new HashSet<>();
        set1.add(s1);
        set1.add(s2);
        System.out.println(set1.size());

        System.out.println("==============");

        String s3 = "cbd";
        String s4 = "cbd";

        System.out.println(s3 == s4);
        System.out.println(s3.equals(s4));
        Set<String> set3 = new HashSet<>();
        set3.add(s3);
        set3.add(s3);
        System.out.println(set3.size());

        System.out.println("==============");

        Person person1 = new Person("abc");
        Person person2 = new Person("abc");
        System.out.println(person1 == person2);
        System.out.println(person1.equals(person2));
        Set<Person> set2 = new HashSet<>();
        set2.add(person1);
        set2.add(person2);
        System.out.println(set2.size());
    }
}
```

最后结果

```
false（==：如果是new出来的对象，比较的时候永远是false）
true：（字符串中的equals被重写过，比较的是值）
1：（HashSet底层是HashMap，HashMap内部是调用equals 和 HashCode，但是String内部的HashCode和equals也被复写）
==============
true（我们通过这种方式创建的会放在一个字符串常量池中，相同的字符串，会指向常量池中同一个对象，因此他们的地址是一样的）
true（字符串中的equals被重写过，比较的是值）
1
==============
false（==：如果是new出来的对象，比较的时候永远是false）
false（Person中的equals没有被重写，相当于等等）
2
```



## 代码二
```java
String s1 = new String("123");
String s2 = "123";
System.out.println(s1 == s2);  //false   s1 返回的是堆内存的对象，s2返回的是常量池的对象

String s1 = new String("123").intern();
String s2 = "123";
System.out.println(s1 == s2);  // true "123"常量池已经存在所以 返回 true


String s1 = new String("123");
/*
严格来说首先肯定会在堆中创建一个123的对象，然后再去判断常量池中是否存在123的对象，
如果不存在，则在常量池中创建一个123的常量(与堆中的123不是一个对象)，
如果存在，则不做任何操作，解决了本文第一个面试题有问到创建几个对象的问题。
因为常量池中是有123的对象的，s指向的是堆内存中的地址值，s.intern()返回是常量池中的123的常量池地址，所以输出false
*/

s1.intern();
String s2 = "123";
System.out.println(s1 == s2);  // false  s1 返回的是堆内存的对象，s2返回的是常量池的对象


String  s = "123";
//true,因为s已经在常量池里面了，s.intern()返回的也是常量池的地址，两者地址一样为true
System.out.println(s == s.intern());


String  s1 = new String("123").intern();
/*
*  首先第一句话 String  s1 = new String("123") 以上分析过创建了两个对象（一个堆中，一个常量池 中）此时s1指向堆中
*  当s1调用.intern()方法之后，发现常量池中已经有了字面量是123的常量，则直接把常量池的地址返回给s1
*  在执行s2等于123时候，去常量池查看，同上常量池已经存在了，则此时s2不创建对象，直接拿常量池123的地址值使用
*  所以此时s1 和 s2 都代表是常量池的地址值，则输出为true
*/
String  s2 = "1"+"23";
System.out.println(s1 == s2);


String s1 = new String("1")+new String("23");
/*
*  首先堆中会有 1 ，23 ，以及相加之后的123 这三个对象。如果 1，23 这两个对象在常量池中没有相等的字面量
*  那么还会在常量池中创建2个对象 最大创建了5个对象。最小创建了3个对象都在堆中。
*/
s1.intern();
String s2 = "123";
System.out.println( s1 == s2);// true


String s1 = new String("1")+new String("23");
String s2 = "123";
s1.intern();
System.out.println( s1 == s2);// false


String s1 = "1"+new String("23");
/*
*首先堆中会有 23 ，以及相加之后的123 这2个对象。如果23,1 这两个对象在常量池中没有相等的字面量
*那么还会在常量池中创建2个对象最大创建了4个对象(2个堆中，2个在常量池中)。最小创建了2个对象都堆中。
*/
String s2 = "123";
System.out.println( s1.intern() == s2);// true



String s1 = "23";
/*
* 这里执行时，常量“1” 会首先到字符串常量池里面去找，如果没有就创建一个，并且加入字符串常量池。
* 得到的123结果对象，不会存入到常量池。这里特别注意和两个常量字符串相加不同 “1”+“23” 参考上面第三点
* 由于不会进入常量池，所以s2 和 s3 常量池地址值不同，所以输出为false
*/
String s2 = "1"+s1;
String s3 = "123";
System.out.println( s2 == s3.intern());
```

参考文章 ： https://zhuanlan.zhihu.com/p/92079662

- 双引号创建字符串 
1. 判断这个常量是否存在于常量池，如果不存在，在常量池中创建该常量，并返回此常量的地址值

- new String创建字符串
1. 首先在堆上创建对象(无论堆上是否存在相同字面量的对象)
2. 然后判断常量池上是否存在字符串的字面量,如果不存在在常量池上创建常量（并将常量地址值返回）

- 两个双引号的字符串相加
1. jvm 会优化 ,判断这两个常量、相加后的常量在常量池上是否存在,如果不存在,则在常量池上创建相应的常量（并将常量地址值返回）,如果存在，则直接返回地址值

- 两个new String（）的字符串相加
1. 首先会创建这两个对象（堆中）以及相加后的对象（堆中）
2. 然后判断常量池中是否存在这两个对象的字面量常量,如果存在,不做任何操作,如果不存在,则在常量池上创建对应常量

- 双引号字符串常量与new String字符串相加
1. 首先创建两个对象，一个是new String的对象（堆中），一个是相加后的对象(堆中)
2. 然后判断双引号字符串字面量和new String的字面量在常量池是否存在
如果存在,不做操作,如果不存在,则在常量池上创建对象的常量


- 双引号字符串常量与一个字符串变量相加
1. 首先创建一个对象，是相加后的结果对象(存放堆中，不会找常量池)
2. 然后判断双引号字符串字面量在常量池是否存在,如果存在,不做操作,如果不存在,则在常量池上创建对象的常量




下面解释关于 intern      方法

```
一句话，intern方法就是从常量池中获取对象
返回字符串对象的规范表示形式
字符串池最初为空，由类字符串私下维护
调用intern方法时，如果池中已包含由equals(Object)方法确定的与此String对象相等的字符串，则返回池中的字符串
否者，此字符串添加到池中，并返回对此字符串对象的引用
因此，对于任意两个字符串s和t，s.intern() == t.intern() 在且仅当 s.equals(t) 为 true时候,所有文字字符串和字符串值常量表达式都会被插入
```

