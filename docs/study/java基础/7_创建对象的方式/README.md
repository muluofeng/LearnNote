###  创建对象的几种方式

- 使用new

- class.forName() 然后使用class.newInstance()

    ```java
    String className = "org.b3log.solo.util.Test";
     Class clasz = Class.forName(className);
     Test t = (Test) clasz.newInstance();
    ```

    

- XXX.class.getConstructor()  然后使用 constructor.newInstance();

    ```javaa
    constructor = Test.class.getConstructor();
     Test t = constructor.newInstance();
    ```

    

- Object 对象的clone 方法

    ```java
    Test t1 = new Test("张三");
     Test t2 = (Test) t1.clone();
     System.out.println(t2.getName());
    ```

    

- **对象反序列化**

```java
 public static void main(String[] args) throws Exception {
 String filePath = "sample.txt";
 Test t1 = new Test("张三");
 try {
   FileOutputStream fileOutputStream =new FileOutputStream(filePath);
   ObjectOutputStream outputStream =new ObjectOutputStream(fileOutputStream);
   outputStream.writeObject(t1);
   outputStream.flush();
   outputStream.close();

   FileInputStream fileInputStream =new FileInputStream(filePath);
   ObjectInputStream inputStream =new ObjectInputStream(fileInputStream);
   Test t2 = (Test) inputStream.readObject();
   inputStream.close();
   System.out.println(t2.getName());
 } catch (Exception ee) {
	 ee.printStackTrace();
 }
 }
```

