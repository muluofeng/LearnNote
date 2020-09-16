#### mybatis是如何和spring进行整合的 



1. 使用jdk的动态代理对mapper的接口生成实现类
2. 生成的实现类使用 ImportBeanDefinitionRegistrar 注入到spring容器中

