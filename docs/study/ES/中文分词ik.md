### ik中文分词

https://github.com/medcl/elasticsearch-analysis-ik

ik中文分词热更新

下载 ik 分词的源码修改

### 1. 修改maven

```xml
## 修改pom的es版本，我这里是7.6.2
        <elasticsearch.version>7.6.2</elasticsearch.version>
## 添加mysql
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.22</version>
        </dependency>

```



### 2. 添加数据库配置文件

 在config目录添加 jdbc-reload.properties

```properties
jdbc.url=
jdbc.user=
jdbc.password=
# 分词
jdbc.reload.sql=select word from sys_keyword
# 停用词
jdbc.reload.stopword.sql=select word from sys_stopword
# 间隔时间 毫秒
jdbc.reload.interval=10000
```



 在指定数据库下创建表

```sql
CREATE TABLE `sys_keyword` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `word` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '词语',
  `last_update` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `sys_stopword` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `word` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '停用词',
  `last_update` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=DYNAMIC;
```



### 3. 修改打包的plugin

 把mysql-connector-java的jar包打包的时候包含

![image-20230306163749151](/Users/muluofeng/Library/Application Support/typora-user-images/image-20230306163749151.png)



```xml
 		 <dependencySet>
            <outputDirectory>/</outputDirectory>
            <useProjectArtifact>true</useProjectArtifact>
            <useTransitiveFiltering>true</useTransitiveFiltering>
            <includes>
                <include>mysql:mysql-connector-java</include>
            </includes>
        </dependencySet>
```



###  4.修改 org.wltea.analyzer.dic.Dictionary

```java
	// prop用来获取上面的properties配置文件
	private static Properties prop = new Properties();

	static {
		try {
			Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			logger.error("error", e);
		}
	}



	private void loadMySqlExtDict() {
		Connection connection = null;
		Statement statement = null;
		ResultSet resultSet = null;

		try {
			Path file = PathUtils.get(getDictRoot(), "jdbc-reload.properties");
			prop.load(new FileInputStream(file.toFile()));

			logger.info("-------jdbc-reload.properties-------");
			for (Object key : prop.keySet()) {
				logger.info("key:{}", prop.getProperty(String.valueOf(key)));
			}

			logger.info("------- 查询词典, sql:{}-------", prop.getProperty("jdbc.reload.sql"));

			// 建立mysql连接
			connection = DriverManager.getConnection(
					prop.getProperty("jdbc.url"),
					prop.getProperty("jdbc.user"),
					prop.getProperty("jdbc.password")
			);

			// 执行查询
			statement = connection.createStatement();
			resultSet = statement.executeQuery(prop.getProperty("jdbc.reload.sql"));

			// 循环输出查询啊结果,添加到Main.dict中去
			while (resultSet.next()) {
				String theWord = resultSet.getString("word");
				if (theWord != null && !"".equals(theWord.trim())) {
					logger.info("------热更新词典:{}------", theWord);
					// 加到mainDict里面
					_MainDict.fillSegment(theWord.trim().toCharArray());
				}
			}
			Thread.sleep(Integer.valueOf(String.valueOf(prop.get("jdbc.reload.interval"))));

		} catch (Exception e) {
			logger.error("error:{}", e);
		} finally {
			try {
				if (resultSet != null) {
					resultSet.close();
				}
				if (statement != null) {
					statement.close();
				}
				if (connection != null) {
					connection.close();
				}
			} catch (SQLException e) {
				logger.error("error", e);
			}
		}
	}


	private void loadMySqlStopwordDict() {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		try {
			Path file = PathUtils.get(getDictRoot(), "jdbc-reload.properties");
			prop.load(new FileInputStream(file.toFile()));

			logger.info("-------jdbc-reload.properties-------");
			for (Object key : prop.keySet()) {
				logger.info("-------key:{}", prop.getProperty(String.valueOf(key)));
			}

			logger.info("-------查询停用词, sql:{}", props.getProperty("jdbc.reload.stopword.sql"));

			conn = DriverManager.getConnection(
					prop.getProperty("jdbc.url"),
					prop.getProperty("jdbc.user"),
					prop.getProperty("jdbc.password"));
			stmt = conn.createStatement();
			rs = stmt.executeQuery(prop.getProperty("jdbc.reload.stopword.sql"));

			while (rs.next()) {
				String theWord = rs.getString("word");
				if (theWord != null && !"".equals(theWord.trim())) {
					logger.info("------- 加载停用词 : {}", theWord);
					_StopWords.fillSegment(theWord.trim().toCharArray());
				}
			}

			Thread.sleep(Integer.valueOf(String.valueOf(prop.get("jdbc.reload.interval"))));
		} catch (Exception e) {
			logger.error("error", e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (stmt != null) {
					stmt.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (SQLException e) {
				logger.error("error:{}", e);
			}

		}
	}

```



添加 线程类

```java
public class HotDicReloadThread {
    private static final Logger logger = ESPluginLoggerFactory.getLogger(HotDicReloadThread.class.getName());

    public void initial() {
        while (true) {
            logger.info("-------重新加载mysql词典--------");
            Dictionary.getSingleton().reLoadMainDict();
        }
    }
}

```



```java
//loadMainDict 最后添加
		//加载mysql自定义词库
		this.loadMySqlExtDict();



// loadStopWordDict方法末尾添加
		//从mysql 加载停用词
		this.loadMySqlStopwordDict();


//initial 在 loadStopWordDict 后面添加
// 执行更新mysql词库的线程
	pool.execute(() -> new HotDicReloadThread().initial());

```



打包项目  在 release 目录下有一个zip包

把原来的 es plugins 目录下的ik删除掉，把上面解压的包发到服务器上





###  5. 重启ES 

处理报错 

```
access denied (java.net.SocketPermission 127.0.0.1:3306 connect,resolve)
java.security.AccessControlException: access denied (permission java.lang.RuntimePermission "setContextClassLoader")
```

把docker  容器内部的security文件映射出来

```yml
 - /data/docker-compose/es/security/default.policy:/usr/share/elasticsearch/jdk/lib/security/default.policy
```



修改 /data/docker-compose/es/security/default.policy在 grant {} 内添加 

```java
grant {
  ....
  permission java.lang.RuntimePermission "setContextClassLoader";
  permission java.net.SocketPermission "mysqlIP:3306","connect,resolve"; 
  permission java.security.SecurityPermission "putProviderProperty.MySQLScramSha1Sasl";
  permission java.security.SecurityPermission "insertProvider.MySQLScramSha1Sasl";
}
```



重启es