### ES 的官网

[免费且开放的搜索：Elasticsearch、ELK 和 Kibana 的开发者 | Elastic](https://www.elastic.co/cn/)

参考资料

- https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzIxMjE3NjYwOQ==&action=getalbum&album_id=1337850434433744897&scene=173&from_msgid=2247483805&from_itemidx=1&count=3&nolastread=1#wechat_redirect





### Es基础概念

 - Cluster 集群，一个集群由一个唯一的名字标识，默认为“elasticsearch”。集群名称非常重要，具有相同集群名的节点才会组成一个集群。集群名称可以在配置文件中指定。
 - Node 节点：存储集群的数据，参与集群的索引和搜索功能。像集群有名字，节点也有自己的名称，默认在启动时会以一个随机的UUID的前七个字符作为节点的名字，你可以为其指定任意的名字。通过集群名在网络中发现同伴组成集群。一个节点也可是集群。
 - Index 索引: 一个索引是一个文档的集合（等同于solr中的集合）。每个索引有唯一的名字，通过这个名字来操作它。一个集群中可以有任意多个索引。

 - Type 类型：指在一个索引中，可以索引不同类型的文档，如用户数据、博客数据。从6.0.0 版本起已废弃，一个索引中只存放一类数据。
 - Document 文档：被索引的一条数据，索引的基本信息单元，以JSON格式来表示。
 - Shard 分片：在创建一个索引时可以指定分成多少个分片来存储。每个分片本身也是一个功能完善且独立的“索引”，可以被放置在集群的任意节点上。
 - Replication 备份: 一个分片可以有多个备份（副本）

![image](https://qiniu.muluofeng.com//uPic/202302/es-introduce-1-3.png)







###   基础数据类型

####  1. String 类型

ES作为全文检索引擎，它强大的地方就在于**分词**和倒排序索引。而 text 和 keyword 的区别就**在于是否分词**（ps：什么叫分词？举个简单例子，“中国我爱你”这句话，如果使用了分词，那么这句话在底层的储存可能就是“中国”、“我爱你”，**被拆分成了两个关键字**）

- text

  就拿刚才的例子来说，“中国我爱你”这句话，如果使用text类型储存，我们不去特殊定义它的分词器，**那么ES就会使用默认的分词器 standard**

​		如果你使用text类型去储存你**本不想分词的string类型**，你在查询的时候，查询结果**将违背你的预期**



```json
{
  "query": {
    "term": {
      "field1": {
        "value": "中国我爱你"
      }
    }
  }
}
```

使用上面的查询会查询不到数据,需要使用下面的查询

```json
{
  "query": {
    "term": {
      "field1": {
        "value": "中"
      }
    }
  }
}
```



这是为什么呢？我们发现在使用term查询（等价于mysql的=）时却查不到结果，其实就是因为**text类型会分词，简单理解就是“中国我爱你”这句话在ES的倒排序索引中存储的是单个字**，所以无法检索。

- Keyword

不会分词

比如

```json
GET /_analyze
{
  "text": ["中国我爱你"],
  "analyzer": "keyword"
}

## 结果
{
  "tokens" : [
    {
      "token" : "中国我爱你",
      "start_offset" : 0,
      "end_offset" : 5,
      "type" : "word",
      "position" : 0
    }
  ]
}

```

给当前索引添加一个字段 nickname 使用keyword

```json
PUT my_index/_mapping/_doc?include_type_name=true
{
  "properties": {
    "nickname": {
      "type": "keyword"
    }
  }
}

# 新增数据
PUT /my_index/_doc/12
{
  "username":"中国我爱你",
   "nickname":"中国我爱你"
}

# 使用term 查询,可以查询到  id =  12的数据
GET /my_index/_doc/_search
{
  "query": {
    "term": {
      "nickname": {
        "value": "中国我爱你"
      }
    }
  }
}
```







### Date 类型

可以设置指定字段支持,**注意：一旦我们规定了格式，如果新增数据不符合这个格式，ES将会报错mapper_parsing_exception。**

```
yyyy-MM-dd HH:mm:ss
yyyy-MM-dd
epoch_millis（毫秒值）
```



### 复杂类型

#### 1. Array

在Elasticsearch中，**数组不需要专用的字段数据类型**。默认情况下，**任何字段都可以包含零个或多个值**，但是，数组中的所有值都**必须具有相同的数据类型。**

```json
PUT my_index/_doc/4
{ "username": ["张三","李四"] }


GET my_index/_search
{
  "query": {
    "match":{
      "username":"张三"
    }
  }
}
```



#### 2. object

object我相信大家都能理解；需要注意的是，**object类型的字段，也可以有多个值**，形成List<object>的数据结构。

重点：List<object>中的**object不允许彼此独立地索引查询**。这是什么意思呢？

举个简单例子：我们现在有2条数据：数据结构都是一个List<object>

```
# 第一条数据：[ { "name":"z1", "age":1 }, { "name":"l1", "age":2 } ]
# 第二条数据：[ { "name":"z1", "age":2 }, { "name":"l1", "age":1 } ]
```



如果此时我们的需求是，只要 **name = “张三”and “age”= 1** 的数据，根据我们常规的理解，只有第一条数据才能被检索出来，但是真的是这样么？我们写个例子看看：

```json
# 添加 属性为object的字段 field3
PUT my_index/_mapping/_doc?include_type_name=true
{
  "properties": {
    "my_obj": {
      "type": "object"
    }
  }
}
# 新增数据
POST /my_index/_doc/3
{
  "my_obj":[{ "name":"z1", "age":1 }, { "name":"l1", "age":2 } ]
}
  
POST /my_index/_doc/4
{
  "my_obj": [  { "name":"z1", "age":2 }, { "name":"l1", "age":1 } ]
}

#执行查询语句,上面 两条都被查询出来了
GET /my_index/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "my_obj.name": "z1"
          }
        },
        {
          "term": {
            "my_obj.age": 1
          }
        }
      ]
    }
  }
}
```

所以 Object 对应被当成了一个整体了， 因为 id=4 数据里面都有 name=z1,age=1,只是在2个对象而已，如果只想一个对应内被检索需要使用nested类型



### 3. nested

> **需要建立对象数组的索引并保持数组中每个对象的独立性，则应使用nested数据类型而不是 object数据类型。在内部，嵌套对象索引阵列作为一个单独的隐藏文档中的每个对象，这意味着每个嵌套的对象可以被独立的查询。**









### 集群的状态

- green 所有的主节点和副本都是active,集群健康
- yellow 至少有一个副本不可用，但是所有的主节点都是active ,数据任然保持完整性
- red 至少一个主节点不可用 ，数据不完整 集群不可用

### 健康值检查

```
GET _cat/health
GET _cluster/health 
```



ES  会自动在node上做分片均衡，比如5个主分片 ，当前有6台服务器，当加入一台新的服务器的时候，会重新对分片进行分配

![image-20230225154430101](https://qiniu.muluofeng.com//uPic/202302/image-20230225154430101.png)

