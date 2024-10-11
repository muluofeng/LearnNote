

###  @AliasFor注解的作用
参考： https://juejin.cn/post/6844904153966182407

####  别名的作用
我们都知道@SpringBootApplication注解，等于@EnableAutoConfiguration，@ComponentScan，@SpringBootConfiguration三个注解的组合。
Spring是怎样将三个注解的整合到一个注解的呢？
这就要说到@AliasFor了

AliasFor可以定义一个注解中的两个属性互为别名
```java 
public @interface ComponentScan {
	@AliasFor("basePackages")
	String[] value() default {};
	
	@AliasFor("value")
	String[] basePackages() default {};
	
	boolean lazyInit() default false;
	...
}

```
有了AliasFor的好处是，如果我们只需要指定basePackages，可以使用value属性，并且省略value属性
@ComponentScan("com.xxx")
如果除了basePackages，还有其他属性，可以使用
@ComponentScan(basePackages = "com.xxx", lazyInit = true)
将value属性换成basePackages，更明确清晰


####   跨注解的属性别名
不仅是一个注解内不同属性可以声明别名，不同注解的属性也可以声明别名（注解可以作用于注解）
```java 
 @Component
public @interface Service {
	@AliasFor(annotation = Component.class)
	String value() default "";
}
```
@Service#value为@Component#value的别名，@Service#value的值可以映射到@Component#value。
（这里我们将@Service，@Component看做一种特殊的继承关系，@Component是父注解，@Service是子注解，@Service#value覆盖@Component#value）

其中 spring 的  @Controller 、@Service 注解都是这样实现的