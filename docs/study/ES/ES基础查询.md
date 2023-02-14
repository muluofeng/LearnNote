

###  查询所有 match_all

```json
GET /bank/_search
## sort 根据指定字段排序
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}
```



###  分页查询

本质上就是from和size两个字段

```json
GET /bank/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ],
  "from": 10,
  "size": 10
}
```



###  指定字段查询 match

如果要在字段中搜索特定字词，可以使用`match`; 如下语句将查询address 字段中包含 mill 或者 lane的数据

```json
GET /bank/_search
{
  "query": { "match": { "address": "mill lane" } }
}
```





###  查询段落匹配：match_phrase

如果我们希望查询的条件是 address字段中包含 "mill lane"，则可以使用`match_phrase`

```json
GET /bank/_search
{
  "query": { "match_phrase": { "address": "mill lane" } }
}
```



###  多条件查询: bool
###  查询条件：query or filter

###  聚合查询：Aggregation

 
