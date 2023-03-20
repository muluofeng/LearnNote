###  Query DSL

查询表达式(Query DSL)是一种非常灵活又富有表现力的 查询语言。 Elasticsearch 使用它可以以简单的 JSON 接口来展现 Lucene 功能的绝大部分。在你的应用中，你应该用它来编写你的查询语句。它可以使你的查询语句更灵活、更精确、易读和易调试



#### 1. 查询上下文

使用query关键字进行检索，倾向于相关度搜索，故需要计算评分。搜索是Elasticsearch最关键和重要的部分。

####  2. 相关度评分:_score

概念:相关度评分用于对搜索结果排序，评分越高则认为其结果和搜索的预期值相关度越高，即越符合搜索预期值。在7.x之前相关法计算而来，7.x之后默认为BM25。在核心知识篇不必关心相关评分的具体原理，只需知晓其概念即可。
排序:相关度评分为搜索结果的排序依据，默认情况下评分越高，则结果越靠前。

### 3. 元数据:_source

1. 禁用_source:

   1. 好处:节省存储开销

   2. 坏处:

```
不支持update、update byquery和reindexAPI。目不支持高亮。

不支持reindex、更改mapping分析器和版本升级。

通过查看索引时使用的原始文档来调试查询或聚合的功能。

将来有可能自动修复索引损坏。

```

总结: **如果只是为了节省磁盘，可以压缩索引比禁用 source更好**

  - 2.数据源过滤器:
    Including:结果中返回哪些field
    Excluding:结果中不要返回哪些field，不返回的field不代表不能通过该字段进行检索，因为元数据不存在不代表索引不存在

    1. 在mapping中定义过滤:支持通配符，但是这种方式不推荐，因为mapping不可变

       ```json
       PUT product
       {
       	"mappings":{
           "_source":{
             "includes":["name","price"],
             "excludes":["desc"]
           }
         }
       }
       ```

       

    2. 常用过滤规则

       ```
       "_source":false
       "_source":"obj.*"
       "_source":["obj1.*","obj2.*"]
       
         "_source":{
             "includes":["obj1.*","obj2.*"],
             "excludes":["desc"]
           }
       
       ```

       

​				

### Query String

### 全文检索 fulltext query

```json
## 基础的语法格式
GET index/_search
{
	"query"：{
  ...
	}
}
```



#### 1.  match all

  ```json
  ## 查询所有 match_all
  GET /bank/_search
  ## sort 根据指定字段排序
  {
    "query": { "match_all": {} },
    "sort": [
      { "account_number": "asc" }
    ]
  }
  
  
  ## 分页查询  本质上就是from和size两个字段
  GET /bank/_search
  {
    "query": { "match_all": {} },
    "sort": [
      { "account_number": "asc" }
    ],
    "from": 10,
    "size": 10
  }
  
  ## 指定字段查询 match
  GET /bank/_search
  {
    "query": { "match": { "address": "mill lane" } }
  }
  
  ```

#### 2. match  匹配包含某个term的子句



```json
PUT product
PUT product/_doc/1
{
  "name":"xiaomi phone",
  "desc":"hot phone"
}

PUT product/_doc/2
{
 "name":"apple phone",
  "desc":"good phone"
}

## 查询文档中name包含phone的数据
GET product/_search
{
  "query":{
    "match": {
      "name": "apple"
    }
  }
}
```



#### 3. multi_match 多个字段包含



  相当于 mysql 中  select * from tableName where a=xx or b=xx

  ```json
  
  
  
  ## multi_match 查询name和desc包含phone的
  GET product/_search
  {
    "query":{
      "multi_match": {
        "query": "phone",
        "fields": ["name","desc"]
      }
    }
  }
  
  ```

  

#### 4. 短语搜索match_phrase

当前检索的字段中 必须包含 指定的词 且词语的顺序不能颠倒

```json
## apple phone 会被分成2个词语  
GET _analyze
{
  "analyzer": "standard",
  "text":"apple phone"
}

## 查询name中包含 apple 且包含 phone的数据，且顺序不能变(中间不能有其他词语)
GET product/_search
{
  "query":{
    "match_phrase": {
      "name": "apple     phone"
    }
  }
}
```



### 5.  精准匹配 exact match

#### 1. term 查询

term和match_phrase的区别 ：

**term不会被检索的关键字分词，match_phrase会把检索的关键字分词**

```json
## name为text 会被分词，查询name 字段被分词后（apple phone会被分为"apple"和 "phone" 两个词 ）包含  "apple phone" 的数据，所以下面的查询没有数据
GET product/_search
{
  "query":{
    "term": {
      "name": "apple phone"
    }
  }
}

## 查询name 字段被分词后包含phone 的数据 ，所以可以被查询到
GET product/_search
{
  "query":{
    "term": {
      "name": "phone"
    }
  }
}
```





term 和 keyword 的区别

**term是对于搜索词不分词，keyword是对于元数据的字段不分词**

当我们使用 动态创建mapping的时候 text 会被自动创建一个keyword的字段 ，默认超过256个字符就会忽略，

比如 name = "apple phone" 如果是text 类型是会被分词成  apple 和 phone 两个词，但是由于name自动创建一个 name.keyword的字段类型为keyword,所以使用  term: { "name.keyword":"apple phone"}  就能查询到

```json
GET product/_search
{
  "query":{
    "term": {
      "name.keyword": "apple phone"
    }
  }
}
```



![image-20230226210851532](https://qiniu.muluofeng.com//uPic/202302/image-20230226210851532.png)





### 7. 过滤器

```json
GET _search
{
  "query":{
  "constant_score": {
    "filter": {
      "term":{
  				"status": "active
      }
    }
}
```



filter:query和filter的主要区别在:filter是结果导向的而querv是过程导向。query倾向于“当前文档和查询的语句的相关度”而filter倾向于”当前文档和查询的
条件是不是相符”。即在查询过程中，query是要对查询的每个结果计算相关性得分的，而filter不会。另外filter有相应的缓存机制，可以提高查询效率。



### 8 组合查询-Bool query

**bool**: 可以组合多个查询条件，bool查询也是采用more matches is better的机制，因此满足must和should子句的文档将会合并起来计算分值

- **must**:必须满足子句(查询)必须出现在匹配的文档中，并将有助于得分。
  - **filter**:过滤器不计算相关度分数，cache☆子句(查询)必须出现在匹配的文档中。但是不像must查询的分数将被忽略。Filter子句在filter上下文中执行。
    这意味着计分被忽略，并且子句被考虑用于缓存。
  - **should**:可能满足 or子句(查询)应出现在匹配的文档中，
  - **must not**:必须不满足 不计算相关度分数 not子句(查询)不得出现在匹配的文档中。子句在过滤器上下文中执行，这意味着计分被忽略，并且子句被视为
    用于缓存。由于忽略计分，0因此将返回所有文档的分数。
  - **minimum should match**:参数指定should返回的文档必须匹配的子句的数量或百分比。如果bool查询包含至少一个should子句，而没有 must或filter子句。则默认值为1，否则，默认值为0

###  多条件查询: bool

###  查询条件：query or filter

###  聚合查询：Aggregation

 