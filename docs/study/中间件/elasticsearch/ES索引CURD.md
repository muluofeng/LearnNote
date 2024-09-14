## 索引的CURD

```json

## 创建索引
PUT /product
## 查看索引
GET /product
GET _cat/indices?v
## 删除索引
DELETE /product

## 
GET /product/_search
## 新增数据
PUT /product/_doc/1
{
  "name": "xiaomi phone",
  "desc": "shouji zhongguo de zhandouji",
  "price": 1399,
  "tags": [
    "fashao",
    "buka",
    "xingjiabi"
  ]
}

PUT /product/_doc/2
{
  "name":"apple phone",
  "desc":"shouji zhongguo de  tianhuaban",
  "price":3999,
  "tags":["fashao","buka","xingjiabi"]
}


## 查看数据
GET /product/_doc/1

## 更新数据（不存在就创建否则字段全量替换）
PUT /product/_doc/1
{

  "price": 1999

}

## 更新指定字段的数据
POST /product/_update/1
{
 "doc":{
     "price":1299
 }
}
```



## 映射Mapping

#### 1. mapping的概念

定义了文档及其包含字段的存储和索引方式的过程，  mapping相当于mysql数据库中的表结构，定义了索引

mapping里面包含了一些属性，比如字段、类型、字段使用的分词器，是否评分等等

### 2.查看mapping

GET  /indexName/_mappings

### 3. ES的数据类型

#### 3.1常见类型

- **数字类型**:
  long integershort byte double float half float scaled float unsigned long

- **Keywords**:
  keyword:适用于索引结构化的字段，可以用于过滤、排序、聚合。keyword类型的字段只能通过精确值(exact value)搜索到。Id应该用keyword

   constant keyword:始终包含相同值的关键字字段
  wildcard:可针对类似erep的通配符查询优化日志行和类似的关键字值
  关键字字段通常用于排序，汇总和Term查询，例如term。

- **Dates**(时间类型):包括date和datenanos

- **alias**:为现有字段定义别名。

-  binary(二进制):binary

- range(区间类型):integer_range、float_range、long range、double_range.date_range

- **text**:当一个字段是要被全文搜索的，比如Email内容、产品描述，这些字段应该使用text类型。设置text类型以后，字段内容会被分析，在生成倒排索引以前，字符串会被分析器分成一个一个词项，text类型的字段不用于排序，很少用于聚合。(解释一下为啥不会为text创建索引:大量堆空间，尤其是在加载高基数text字段时。字段数据一旦加载到堆中，就在该段的生命周期内保持在那里。同样，加载字段数据是一个昂贵的过程，可能导致用户遇到延迟问题。这就是默认情况下禁用字段数据的原因)

#### 3.2对象关系类型:

- **object**:用于单个JSON对象
- **nested**:用于JSON对象数组

- flattened:允许将整个JSON对象索引为单个字段。

#### 3.3  结构化类型:

- geo-point:纬度/经度积分

- geo-shape:用于多边形等复杂形状3) point:笛卡尔坐标点

- shape:笛卡尔任意几何图形

  

#### 3.4  特殊类型:

- IP地址:ip 用于IPv4和IPv6地址
- [completion](#completion-suggester):提供自动完成建议*

- tocken_count:计算字符串中令牌的数量
- murmur3:在索引时计算值的哈希并将其存储在索引中
- annotated-text:索引包含特殊标记的文本(通常用于标识命名实体

- percolator:接受来自query-dsl的查询

- join:为同一索引内的文档定义父/子关系

- rank features:记录数字功能以提高查询时的点击率，

- dense vector:记录浮点值的密集向量。

- sparse vector:记录浮点值的稀疏向量。
  11)search-as-you-type:针对查询优化的文本字段，以实现按需输入的完成

- histogram:histogram 用于百分位数聚合的预聚合数值。

- constant keyword:keyword当所有文档都具有相同值时的情况的 专业化。
  5arrav(数组):在Elasticsearch中，数组不需要专用的字段数据类型，默认情况下，任何字段都可以包含零个或多个值，但是，数组中的所有值都必须具有相同的数据类型。

  

  

2种映射方式

- 动态映射

  ```
  整数             => long   
  浮点数 				  => float
  true || false   => boolean
  日期             => date
  数组             => 取决于数组中第一个有效值
  对象             => object
  字符串           =>  如果不是数字和日期类型，都会被识别为 text 和 keyword 两个类型       
  ```

  

  除了以上字段类型之外，其他类型都必须显示映射，也就是必须手动指定，因为其他类型无法自动识别

  

 ```json
 
 PUT  /product_2
 {
    "name":"zhanshan",
    "desc":"zhanshan 123",
    "count":1234,
    "price":1.00,
    "isDel":false,
    "tags":[
     "gg","xx1"
   ],
 }
 
 ##  或者对应索引的映射
 GET   /product_2/_mapping
 {
   "product_2" : {
     "mappings" : {
       "properties" : {
         "count" : {
           "type" : "long"
         },
         "desc" : {
           "type" : "text",
           "fields" : {
             "keyword" : {
               "type" : "keyword",
               "ignore_above" : 256
             }
           }
         },
         "isDel" : {
           "type" : "boolean"
         },
         "name" : {
           "type" : "text",
           "fields" : {
             "keyword" : {
               "type" : "keyword",
               "ignore_above" : 256
             }
           }
         },
         "price" : {
           "type" : "float"
         },
         "tags" : {
           "type" : "text",
           "fields" : {
             "keyword" : {
               "type" : "keyword",
               "ignore_above" : 256
             }
           }
         }
       }
     }
   }
 }
 
 ```



- 静态映射

  ```json
  ##创建索引并且指定字段的mapping 
  PUT /product_3
  {
    "mappings":{
      "properties":{
         "username":{
           "type":"text"
         }
      }
    }
  }
  
  ## 手动创建的mapping(fields的mappings只能创建，无法修改)，比如下面的就会报错，无法把username从text改编成long
  
  PUT /product_3/mapping
  {
      "properties":{
         "username":{
           "type":"long"
         }
      }
  }
  
  
  
  
  ```

  ## 静态映射除了type有很多属性,比如 analyzer、boost
  1. **index 是否对当前字段创建倒排索引，默认是true**
  2. **analyzer 指定分词器**
  3. boost 对当前字段相关度的权重 默认1
  4. coerce 是否允许强制类型转换   "1" =>1
  5. copy_to  允许将多个字段的值赋值到数组字段中，可以将其作为单个字段进行查询
  6. **doc_values 为了提升和聚合效率，默认为true,如果不确定要对字段进行排序或者聚合，也不需要通过脚本访问字段，则可以禁用doc值已节省磁盘空间**
  6. **fileds 给filed创建多个字段，用于不同的目的（全文检索或者聚合分析排序）**
  6. fileddata  由于text类型的数据没有办法创建正排索引，但是又想按照该字段排序和聚合可以使用 fielddata = true

​       todo  还有很多的属性

fileds 使用

```json
## 创建索引 city 分词(text不能用排序聚合等)，且为关键字
PUT fields_test
{
  "mappings": {
    "properties": {
      "city":{
        "type": "text",
        "fields": {
          "raw":{
            "type":"keyword"
          }
        }
      }
    }
  }
}
PUT fields_test/_doc/1
{
  "city":"New York"
}

PUT fields_test/_doc/2
{
  "city":"York"
}

## 查看索引
GET fields_test/_mapping
## 上一步的结果
{
  "fields_test" : {
    "mappings" : {
      "properties" : {
        "city" : {
          "type" : "text",
          "fields" : {
            "raw" : {
              "type" : "keyword"
            }
          }
        }
      }
    }
  }
}

## 查询 根据 city.raw 排序和聚合，如果使用city字段排序和聚合就会报错
GET fields_test/_search
{
  "query": {
    "match": {
      "city": "york"
    }
  },
  "sort":{
    "city.raw":"desc"
  },
  "aggs": {
    "cities": {
      "terms": {
        "field": "city.raw"
        }
    }
  }
}
```

fielddata 使用

```json
## 由于city 是 text 不支持聚合，下面的查询会报错
GET fields_test/_search
{
  "aggs": {
    "cities": {
      "terms": {
        "field": "city"
        }
    }
  }
}

## 将文本的field的fielddata属性设置为true ，然后使用上面的查询就正常了
PUT fields_test/_mapping
{
  "properties":{
    "city":{
      "type":"text",
      "fielddata":true
    }
  }
}
```



