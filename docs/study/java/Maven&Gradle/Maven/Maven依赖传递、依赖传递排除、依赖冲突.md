##  Maven依赖传递

    假如有Maven项目A，项目B依赖A，项目C依赖B。那么我们可以说 C依赖A。也就是说，依赖的关系为：C—>B—>A。
    
    那么我们执行项目C时，会自动把B、A都下载导入到C项目的jar包文件夹中。
    
    这就是依赖的传递性。

 


    二：依赖传递的排除
    
    如上，C—>B—>A。加入现在不想执行C时把A下载进来，那么我们可以用 <exclusions>标签。

复制代码

```xml
<dependencies>
    <dependency>
        <groupId>B</groupId>
        <artifactId>B</artifactId>
        <version>0.0.1</version>

         <exclusions>
            <exclusion>
              <!--被排除的依赖包坐标-->
              <groupId>A</groupId>
              <artifactId>A</artifactId>
              <version>0.0.1</version>
            </exclusion>
         </exclusions>
    </dependency>
</dependencies>
 
```

### 依赖冲突与解决

    依赖冲突：一个项目A，通过不同依赖传递路径依赖于X，若在不同路径下传递过来的X版本不同，那么A应该导入哪个版本的X包呢？
    
    冲突解决方案：
    
    1：如果依赖路径的长度不同，则“短路优先”：
    
         A—>B—>C—>D—>E—>X(version 0.0.1)
    
         A—>F—>X(version 0.0.2)
    
         则A依赖于X(version 0.0.2)。
    
     2：依赖路径长度相同情况下，则“先声明优先”：
    
         A—>E—>X(version 0.0.1)
    
         A—>F—>X(version 0.0.2)
    
         则在项目A的<depencies></depencies>中，E、F那个在先则A依赖哪条路径的X。


​         
​         
​         
​         
​         
​         
##  可选依赖         
Optional定义后，该依赖只能在本项目中传递，不会传递到引用该项目的父项目中，父项目需要主动引用该依赖才行。

比如
    
    Project-X -> Project-A
    Project-A -> Project-B

```xml
<project>
  ...
  <dependencies>
    <dependency>
      <groupId>sample.ProjectB</groupId>
      <artifactId>Project-B</artifactId>
      <version>1.0</version>
      <scope>compile</scope>
      <optional>true</optional>
    </dependency>
  </dependencies>
</project>
```

如上X依赖A，A依赖B用的<optional>true</optional>，这时B只能在A中使用，而不会主动传递到X中，X需要主动引用B才有B的依赖。
    