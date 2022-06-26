

###  java 8 函数式接口

函数式接口定义：

接口中只有一个抽象方法的口,称为函数式接口,可以使用注解@FunctionInterface 修饰
内置的一些FunctionInterface、接口


##### 1. Consumer 消费型接口
BiConsumer<String, String> 支持2个参数，Consumer 支持一个参数
***void accept(T t);***
```java

    public static void consumer(String str, Consumer consumer) {
        consumer.accept(str);
    }

    public static void biconsumer(String s1, String s2, BiConsumer<String, String> consumer) {
        consumer.accept(s1, s2);
    }

     public static void main(String[] args) {
        consumer("hello world", str -> System.out.println("this is " + str));
        biconsumer("hello ", "world", (s1, s2) -> System.out.println(s1 + s2));
    }
    
```
##### 2. Supplier 供给型接口
***T get();***


```java
@Test
public void test6(){
    List num = getNum(10, () -> (int) (Math.random() * 100));
    num.forEach(System.out::println);
}

public List getNum(int num, Supplier supplier){
    ArrayList integers = new ArrayList<>();
    for (int i = 0; i < num; i++) {
        integers.add(supplier.get());
    }
    return integers;
}
```


 ##### 3. Function<T,R> 函数型接口
***R apply(T t);***
```java
     public static void main(String[] args) {
    
        function("hello",(s1)->s1+" xxx");
        bifunction("hello","world",(s1,s2)->s1+s2+" xxx");
    }
    public static void function(String s1,Function<String, String> function){
        System.out.println(function.apply(s1));
    }
    public static void bifunction(String s1,String s2, BiFunction<String, String,String> function){
        System.out.println(function.apply(s1,s1));
    }
```
 ##### 4.Predicate 断言型接口
***boolean test(T t);***

```java
@Test
public void test8(){
    boolean query = isQuery("select query", s -> s.equals("select query"));
    System.out.println(query);
}

public boolean isQuery(String string, Predicate predicate){
    return predicate.test(string);
}
```