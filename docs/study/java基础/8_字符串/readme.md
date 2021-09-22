#### Stirng.intern() 方法



- 直接使用双引号声明出来的`String`对象会直接存储在常量池中。 比如 String  a ="11";
- 而 new 出来的 String 对象是放在 JAVA Heap 区域  比如 String  a = new String("11");    同时 如果常量池不存在 ”11“也会在  常量池  写入 11
- intern 方法 返回 Java查找常量池中是否有相同Unicode的字符串常量，如果有，则返回其的引用，如果没有，则在常量池中增加一个Unicode等于str的字符串并返回 原来字符串的引用

