#### 事务的嵌套概念

```
所谓事务的嵌套就是两个事务方法之间相互调用。
spring事务开启 ，或者是基于接口的或者是基于类的代理被创建（注意一定要是代理，不能手动new 一个对象，
并且此类（有无接口都行）一定要被代理——spring中的bean只要纳入了IOC管理都是被代理的）。
所以在同一个类中一个方法调用另一个方法有事务的方法，事务是不会起作用的。
```


Spring默认情况下会对运行期例外(RunTimeException)，即uncheck异常，进行事务回滚。
如果遇到checked异常就不回滚。
如何改变默认规则：

1 让checked例外也回滚：在整个方法前加上

```java
@Transactional(rollbackFor=Exception.class)
```





2 让unchecked例外不回滚： 

```java
@Transactional(notRollbackFor=RunTimeException.class)
```





3 不需要事务管理的(只查询的)方法：@Transactional(propagation=Propagation.NOT_SUPPORTED)
上面三种方式也可在xml配置


#### spring事务传播属性

 在 spring的 TransactionDefinition接口中一共定义了七种事务传播属性：

- PROPAGATION_REQUIRED -- 支持当前事务，如果当前没有事务，就新建一个事务。这是最常见的选择。 
- PROPAGATION_SUPPORTS -- 支持当前事务，如果当前没有事务，就以非事务方式执行。 
- PROPAGATION_MANDATORY -- 支持当前事务，如果当前没有事务，就抛出异常。 
- PROPAGATION_REQUIRES_NEW -- 新建事务，如果当前存在事务，把当前事务挂起。 
- PROPAGATION_NOT_SUPPORTED -- 以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。 
- PROPAGATION_NEVER -- 以非事务方式执行，如果当前存在事务，则抛出异常。 
- PROPAGATION_NESTED -- 如果当前存在事务，则在嵌套事务内执行。如果当前没有事务，则进行与PROPAGATION_REQUIRED类似的操作。 





```java
ServiceA {  
         
     void methodA() {  
         ServiceB.methodB();  
     }  
    
}  
ServiceB {  
         
     void methodB() {  
     }  
         
}  
```


###### ==在外围方法开启事务的情况下Propagation.REQUIRED修饰的内部方法会加入到外围方法的事务中，所有Propagation.REQUIRED修饰的内部方法和外围方法均属于同一事务，只要一个方法回滚，即使内部方法的异常被外部捕获，整个事务均回滚==

###### ==在外围方法开启事务的情况下Propagation.REQUIRES_NEW修饰的内部方法依然会单独开启独立事务，且与外部方法事务也独立，内部方法之间、内部方法和外部方法事务均相互独立，互不干扰。内部方法的异常被外部捕获，就不会被外部感知到，否则会影响到==

###### ==外围方法未开启事务的情况下Propagation.NESTED和Propagation.REQUIRED作用相同，修饰的内部方法都会新开启自己的事务，且开启的事务相互独立，互不干扰==

###### ==在外围方法开启事务的情况下Propagation.NESTED修饰的内部方法属于外部事务的子事务，外围主事务回滚，子事务一定回滚，而内部子事务可以单独回滚而不影响外围主事务和其他子事务，内部方法的异常被外部捕获，就不会被外部感知到，否则会影响到==


代码案例参考：https://juejin.im/post/5ae9639af265da0b926564e7#heading-8





**外围方法开启事务的情况下`Propagation.REQUIRED`修饰的内部方法会加入到外围方法的事务中，所有`Propagation.REQUIRED`修饰的内部方法和外围方法均属于同一事务，只要一个方法回滚，整个事务均回滚**

