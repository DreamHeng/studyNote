# ElasticSearch

## 1.概述

### ElasticSearch是什么?

​	ElasticSearch是一个基于Lucene的搜索服务器。它提供了一个分布式多用户能力的全文搜索引擎，基于RESTful web接口。ElasticSearch是用Java开发的，并作为Apache许可条款下的开放源码发布，是当前流行的企业级搜索引擎。设计用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。

ElasticSearch不仅仅是Lucene和全文搜索引擎，它还提供：

- 分布式的搜索引擎和数据分析引擎
- 全文检索
- 对海量数据进行近实时的处理

### ES的应用场景

- **全文检索**：主要和 Solr 竞争，属于后起之秀。

- NoSQL JSON文档数据库：**主要抢占 Mongo 的市场**，它在读写性能上优于 Mongo ，同时也**支持地理位置查**

  **询**，还方便**地理位置和文本混合查询**。

- 监控：统计、日志类时间序的数据存储和分析、可视化，这方面是引领者。

- 国外：Wikipedia（维基百科）使用ES提供全文搜索并高亮关键字、StackOverflow（IT问答网站）结合全文搜

  索与地理位置查询、Github使用Elasticsearch检索1300亿行的代码。

- 国内：百度（在云分析、网盟、预测、文库、钱包、风控等业务上都应用了ES，单集群每天导入30TB+数据，

  总共每天60TB+）、新浪 、阿里巴巴、腾讯等公司均有对ES的使用。

- 使用比较广泛的平台ELK(ElasticSearch, Logstash, Kibana)。

## 2.基本概念

### RESTful介绍

参考资料：
1. http://www.ruanyifeng.com/blog/2011/09/restful.html
2. http://www.ruanyifeng.com/blog/2018/10/restful-api-best-practices.html

REST : 表现层状态转化(Representational State Transfer)，如果一个架构符合REST原则，就称它为 RESTful 架构风
格。

- **资源**： 所谓"资源"，就是网络上的一个实体，或者说是网络上的一个具体信息

- **表现层**：我们把"资源"具体呈现出来的形式，叫做它的"表现层"（Representation）。

- **状态转化**（State Transfer）：如果客户端想要操作服务器，必须通过某种手段，让服务器端发生"状态转

  化"（State Transfer）。而这种转化是建立在表现层之上的，所以就是"表现层状态转化"。就是HTTP协议里

  面，四个表示操作方式的动词：GET、POST、PUT、DELETE。它们分别对应四种基本操作：GET用来获取资

  源，POST用来新建资源（也可以用于更新资源），PUT用来更新资源，DELETE用来删除资源。

### ES中涉及到的重要概念

#### 接近实时（NRT）

​	Elasticsearch是一个接近实时的搜索平台。这意味着，从索引一个文档直到这个文档能够被搜索到有一个轻微的延迟（通常是1秒）

#### 集群（cluster）

​	一个集群就是由一个或多个节点组织在一起，它们共同持有整个的数据，并一起提供索引和搜索功能。一个集群由一个唯一的名字标识，这个名字默认就是“elasticsearch”。这个名字是重要的，因为一个节点只能通过指定		某个集群的名字，来加入这个集群。在产品环境中显式地设定这个名字是一个好习惯，但是使用默认值来进行测试/开发也是不错的。

#### 节点（node）

​	一个节点是你集群中的一个服务器，作为集群的一部分，它存储你的数据，参与集群的索引和搜索功能。和集群类似，一个节点也是由一个名字来标识的，默认情况下，这个名字是一个随机的漫威漫画角色的名字，这个名字会在启动的时候赋予节点。这个名字对于管理工作来说挺重要的，因为在这个管理过程中，你会去确定网络中的哪些服务器对应于Elasticsearch集群中的哪些节点。
​	一个节点可以通过配置集群名称的方式来加入一个指定的集群。默认情况下，每个节点都会被安排加入到一个叫做“elasticsearch”的集群中，这意味着，如果你在你的网络中启动了若干个节点，并假定它们能够相互发现彼此，它们将会自动地形成并加入到一个叫做“elasticsearch”的集群中。
在一个集群里，只要你想，可以拥有任意多个节点。而且，如果当前你的网络中没有运行任何Elasticsearch节点，
这时启动一个节点，会默认创建并加入一个叫做“elasticsearch”的集群。

#### 索引（index）

​	一个索引就是一个拥有几分相似特征的文档的集合。比如说，你可以有一个客户数据的索引，另一个产品目录的索引，还有一个订单数据的索引。一个索引由一个名字来标识（必须全部是小写字母的），并且当我们要对对应于这个索引中的文档进行索引、搜索、更新和删除的时候，都要使用到这个名字。索引类似于关系型数据库中Database的概念。在一个集群中，如果你想，可以定义任意多的索引。

#### 类型（type）

​	在一个索引中，你可以定义一种或多种类型。一个类型是你的索引的一个逻辑上的分类/分区，其语义完全由你来定。通常，会为具有一组共同字段的文档定义一个类型。比如说，我们假设你运营一个博客平台并且将你所有的数据存储到一个索引中。在这个索引中，你可以为用户数据定义一个类型，为博客数据定义另一个类型，当然，也可以为评论数据定义另一个类型。类型类似于关系型数据库中Table的概念。

#### 文档（document）

​	一个文档是一个可被索引的基础信息单元。比如，你可以拥有某一个客户的文档，某一个产品的一个文档，当然，也可以拥有某个订单的一个文档。文档以JSON（Javascript Object Notation）格式来表示，而JSON是一个到处存在的互联网数据交互格式。
​	在一个index/type里面，只要你想，你可以存储任意多的文档。注意，尽管一个文档，物理上存在于一个索引之中，文档必须被索引/赋予一个索引的type。文档类似于关系型数据库中Record的概念。实际上一个文档除了用户定义的数据外，还包括index、 type和_id字段

#### 分片和复制（shards & replicas）

​	一个索引可以存储超出单个结点硬件限制的大量数据。比如，一个具有10亿文档的索引占据1TB的磁盘空间，而任一节点都没有这样大的磁盘空间；或者单个节点处理搜索请求，响应太慢。
​	为了解决这个问题，Elasticsearch提供了将索引划分成多份的能力，这些份就叫做分片。当你创建一个索引的时候，你可以指定你想要的分片的数量。每个分片本身也是一个功能完善并且独立的“索引”，这个“索引”可以被放置到集群中的任何节点上。 

分片之所以重要，主要有两方面的原因：

- 允许你水平分割/扩展你的内容容量

- 允许你在分片（潜在地，位于多个节点上）之上进行分布式的、并行的操作，进而提高性能/吞吐量 至于一个

  分片怎样分布，它的文档怎样聚合回搜索请求，是完全由Elasticsearch管理的，对于作为用户的你来说，这些

  都是透明的。

在一个网络/云的环境里，失败随时都可能发生，在某个分片/节点不知怎么的就处于离线状态，或者由于任何原因
消失了。这种情况下，有一个故障转移机制是非常有用并且是强烈推荐的。为此目的，Elasticsearch允许你创建分
片的一份或多份拷贝，这些拷贝叫做复制分片，或者直接叫复制。复制之所以重要，主要有两方面的原因：

- 在分片/节点失败的情况下，提供了高可用性。因为这个原因，注意到复制分片从不与原/主要

  （original/primary）分片置于同一节点上是非常重要的。

- 扩展你的搜索量/吞吐量，因为搜索可以在所有的复制上并行运行

总之，每个索引可以被分成多个分片。一个索引也可以被复制0次（意思是没有复制）或多次。一旦复制了，每个
索引就有了主分片（作为复制源的原来的分片）和复制分片（主分片的拷贝）之别。分片和复制的数量可以在索引
创建的时候指定。在索引创建之后，你可以在任何时候动态地改变复制数量，但是不能改变分片的数量。
默认情况下，Elasticsearch中的每个索引被分片5个主分片和1个复制，这意味着，如果你的集群中至少有两个节
点，你的索引将会有5个主分片和另外5个复制分片（1个完全拷贝），这样的话每个索引总共就有10个分片。一个
索引的多个分片可以存放在集群中的一台主机上，也可以存放在多台主机上，这取决于你的集群机器数量。主分片
和复制分片的具体位置是由ES内在的策略所决定的。

#### 映射（Mapping）

​	Mapping是ES中的一个很重要的内容，它类似于传统关系型数据中table的schema，用于定义一个索引（index）的某个类型（type）的数据的结构。
​	在ES中，我们无需手动创建type（相当于table）和mapping(相关与schema)。在默认配置下，ES可以根据插入的数据自动地创建type及其mapping。
mapping中主要包括字段名、字段数据类型和字段索引类型

## 3.ES环境搭建

1. 准备

   - CentOS（版本需大于 7  如： CentOS-7-x86_64-Minimal-1804.iso ）

   - Java(版本需大于 1.8  如： jdk-8u181-linux-x64.rpm )

   - ES安装包（如： elasticsearch-6.4.0.tar.gz ）

   - 修改网卡

     ```shell
     vi /etc/sysconfig/network-scripts/ifcfg-ens33
     ```

   - 重启网卡服务

     ```shell
     systemctl restart network 
     ```

   - 关闭防火墙

     ```shell
     systemctl stop firewalld   (centos6 : service iptables stop)
     systemctl disable firewalld (centos6 : chkconfig iptables off)
     ```

   - 查看ip

     ```shell
     ip a
     ```

2. 安装java

   ```shell
   # rpm -ivh jdk-8u181-linux-x64.rpm -C /usr/
   
   配置环境变量(rpm java可不用)
   # vi /etc/profile
   export JAVA_HOME=/usr/java/latest
   export CLASSPATH=.
   export PATH=$PATH:$JAVA_HOME/bin
   
   更新资源
   # source /etc/profile
   ```

3. 安装ES

   ```shell
   # tar -zxvf elasticsearch-6.4.0.tar.gz -C /usr/
   ```

4. 启动ES服务

   ```shell
   [root@bogon bin]# ./elasticsearch
   ```

   ==ES不允许通过ROOT用户启动==

   解决方案:

   - 创建普通用户，修改目录所属

     ```shell
     # groupadd es
     # useradd -g es es
     # chown -R es:es /usr/elasticsearch-6.4.0/
     ```

   - 切换用户

     ```shell
     su es
     ```

   - 启动

5. 测试

   ```shell
   # curl -X GET localhost:9200
   {
     "name" : "OC03Lum",
     "cluster_name" : "elasticsearch",
     "cluster_uuid" : "S0V8yt6KTaWZyKaZhDSBuA",
     "version" : {
       "number" : "6.4.0",
       "build_flavor" : "default",
       "build_type" : "tar",
       "build_hash" : "595516e",
       "build_date" : "2018-08-17T23:18:47.308994Z",
       "build_snapshot" : false,
       "lucene_version" : "7.4.0",
       "minimum_wire_compatibility_version" : "5.6.0",
       "minimum_index_compatibility_version" : "5.0.0"
     },
     "tagline" : "You Know, for Search"
   }
   ```

6. 配置远程访问

   ```shell
   vim config/elasticsearch.yml
   
   显示行号 
   :set nu
   
   51 # ---------------------------------- Network -----------------------------------
   52 #
   53 # Set the bind address to a specific IP (IPv4 or IPv6):
   54 #
   55 network.host: 192.168.30.135
   56 #
   57 # Set a custom port for HTTP:
   58 #
   59 #http.port: 9200
   60 #
   61 # For more information, consult the network module documentation.
   62 #
   63 # --------------------------------- Discovery ----------------------------------
   ```

7. 重新启动ES服务，出现异常

   解决方案：切换到root用户修改配置文件

   ```shell
   # vi /etc/security/limits.conf
   # 添加以下内容
   * soft nofile 65536
   * hard nofile 131072
   * soft nproc 2048
   * hard nproc 4096
   
   # vi /etc/sysctl.conf
   # 添加以下内容
   vm.max_map_count=655360
   
   测试配置是否成功
   # sysctl -p
   vm.max_map_count = 655360
   
   重启虚拟机
   reboot
   ```

### 安装Kibana

​	Kibana是一个针对Elasticsearch的开源数据分析及可视化平台，用来搜索、查看交互存储在Elasticsearch索引中的数据。使用Kibana，可以通过各种图表进行高级数据分析及展示。

​	Kibana让海量数据更容易理解。它操作简单，基于浏览器的用户界面可以快速创建仪表板（dashboard）实时显示Elasticsearch查询动态。
​	设置Kibana非常简单。无需编码或者额外的基础架构，几分钟内就可以完成Kibana安装并启动Elasticsearch索引监测。

1. 安装配置

   ```shell
   # tar -zxvf kibana-6.4.0-linux-x86_64.tar.gz -C /usr
   # cd /usr/kibana-6.4.0-linux-x86_64/
   
   修改配置文件
   # vi config/kibana.yml
   
   # To allow connections from remote users, set this parameter to a non-loopback address.
   第七行 server.host: "192.168.23.141"
   # The URL of the Elasticsearch instance to use for all your queries.
   第28行 elasticsearch.url: "http://192.168.23.141:9200"
   
   启动服务
   [root@localhost kibana-6.4.0-linux-x86_64]# bin/kibana
   ```

2. 启动测试

   ```
   "http://192.168.23.141:5601"
   ```

## 4.使用Kibana实现基本的增删改查

```json
#查看集群健康信息
GET /_cat/health?v

#查看集群节点信息
GET /_cat/nodes?v

#查看集群索引信息
GET /_cat/indices?v
#简化写法
GET /_cat/indices?v&h=health,status,index

#创建索引
PUT /heng
#删除索引
DELETE /heng

#创建类型Mapping(创建索引heng并添加类型meng)
PUT /heng
{
  "mappings": {
    "meng":{
      "properties":{
        "id":{"type":"text"},
        "name":{"type":"text"},
        "age":{"type":"integer"}
      }
    }
  }
}
#在创建索引heng后，向这个索引添加类型_meng
POST /heng/user
{
  "user":{
      "properties":{
        "id":{"type":"text"},
        "name":{"type":"text"},
        "age":{"type":"integer"}
      }
    }
}
#查看类型的mapping
GET /heng/_mapping/user

#新增文档
PUT /heng/user/1
{
  "name":"恒",
  "age":18
}
#自动生成ID
POST /heng/user
{
  "name":"梦",
  "age":18
}
#查看单个文档
GET /heng/user/1
GET /heng/user/Sid_SGkBXCX4ilyPzlzG
#修改单个文档
PUT /heng/user/Ryd1SGkBXCX4ilyPrlyX
{
  "name":"李梦",
  "age":19
}
#删除单个文档
DELETE /heng/user/Ryd1SGkBXCX4ilyPrlyX

#批量插入文档
POST /heng/user/_bulk
{"index":{}}
{"name":"小恒","age":10}
{"index":{}}
{"name":"小梦","age":20}

#批量修改文档
POST /heng/user/_bulk
{"update":{"_id":"Sid_SGkBXCX4ilyPzlzG"}}
{"doc":{"name":"小小恒"}}
{"delete":{"_id":"1"}}

#查询所有文档并按照年龄倒序排列
GET /heng/user/_search
{
  "query": {
    "match_all": {}
  },
  "sort": {
    "age": "desc"
    }
}
```

## 5.深入搜索

### 搜索方式 

​	搜索有两种方式：一种是通过 URL 参数进行搜索，另一种是通过 DSL(Request Body) 进行搜索

> DSL：Domain Specified Language，特定领域语言
> 使用请求体可以让你的JSON数据以一种更加可读和更加富有展现力的方式发送

### 导入测试数据

```json
#新建index(zpark),并添加mapping(user)
POST /zpark/user
{
  "user":{
    "properties":{
      "id":{"type":"text"},
      "name":{"type":"text"},
      "realname":{"type":"text"},
      "age":{"type":"integer"},
      "birthday":{
        "type":"date",
        "format":"strict_date_optional_time||epoch_millis"
      },
      "salary":{"type":"float"},
      "address":{"type":"text"}
    }
  }
}
# 批量插入测试数据
POST /zpark/user/_bulk
{"index":{"_id":1}}
{"name":"zs","realname":"张三","age":18,"birthday":"2018-12-27","salary":1000.0,"address":"北京市昌平区沙阳路18号"}
{"index":{"_id":2}}
{"name":"ls","realname":"李四","age":20,"birthday":"2017-10-20","salary":5000.0,"address":"北京市朝阳区三里屯街道21号"}
{"index":{"_id":3}}
{"name":"ww","realname":"王五","age":25,"birthday":"2016-03-15","salary":4300.0,"address":"北京市海淀区中关村大街新中关商城2楼511室"}
{"index":{"_id":4}}
{"name":"zl","realname":"赵六","age":20,"birthday":"2003-04-19","salary":12300.0,"address":"北京市海淀区中关村软件园9号楼211室"}
{"index":{"_id":5}}
{"name":"tq","realname":"田七","age":35,"birthday":"2001-08-11","salary":1403.0,"address":"北京市海淀区西二旗地铁辉煌国际大厦负一楼"}
```

### 查询

#### 查询所有并排序

```json
#查看该索引下user类型所有文档
#DSL实现
GET /zpark/user/_search
{
  "query": {
    "match_all": {}
  },
  "sort":{
    "salary":"desc"
  }
}
#URL实现
GET /zpark/user/_search?q=*&sort=age:desc&pretty

```



#### 分页查询

```json
#分页实现,from表示第几条开始（0开始），size表示一页大小
GET /zpark/user/_search
{
  "query": {
    "match_all": {}
  },
  "sort":{
    "_id":"asc"
  },
  "from": 0,
  "size": 2
}
GET /zpark/user/_search?q=*&sort=_id:asc&from=0&size=2
```

#### 查询address在海淀区的用户，并高亮显示

> 基于全文检索的查询（分析检索关键词 匹配索引库 返回结果）

```json
#查询address为海淀区的，并高亮
GET /zpark/user/_search
{
  "query": {
    "match": {
      "address": "海淀区"
    }
  },
  "highlight": {
    "fields": {
      "address": {}
    }
  }
}

```

**查询结果：**

```json
{
  "took": 23,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 5,
    "max_score": 1.4874805,
    "hits": [
      {
        "_index": "zpark",
        "_type": "user",
        "_id": "4",
        "_score": 1.4874805,
        "_source": {
          "name": "zl",
          "realname": "赵六",
          "age": 20,
          "birthday": "2003-04-19",
          "salary": 12300,
          "address": "北京市海淀区中关村软件园9号楼211室"
        },
        "highlight": {
          "address": [
            "北京市<em>海</em><em>淀</em><em>区</em>中关村软件园9号楼211室"
          ]
        }
      },
      {
        "_index": "zpark",
        "_type": "user",
        "_id": "5",
        "_score": 0.8630463,
        "_source": {
          "name": "tq",
          "realname": "田七",
          "age": 35,
          "birthday": "2001-08-11",
          "salary": 1403,
          "address": "北京市海淀区西二旗地铁辉煌国际大厦负一楼"
        },
        "highlight": {
          "address": [
            "北京市<em>海</em><em>淀</em><em>区</em>西二旗地铁辉煌国际大厦负一楼"
          ]
        }
      },
      {
        "_index": "zpark",
        "_type": "user",
        "_id": "3",
        "_score": 0.8630463,
        "_source": {
          "name": "ww",
          "realname": "王五",
          "age": 25,
          "birthday": "2016-03-15",
          "salary": 4300,
          "address": "北京市海淀区中关村大街新中关商城2楼511室"
        },
        "highlight": {
          "address": [
            "北京市<em>海</em><em>淀</em><em>区</em>中关村大街新中关商城2楼511室"
          ]
        }
      },
      {
        "_index": "zpark",
        "_type": "user",
        "_id": "1",
        "_score": 0.2876821,
        "_source": {
          "name": "zs",
          "realname": "张三",
          "age": 18,
          "birthday": "2018-12-27",
          "salary": 1000,
          "address": "北京市昌平区沙阳路18号"
        },
        "highlight": {
          "address": [
            "北京市昌平<em>区</em>沙阳路18号"
          ]
        }
      },
      {
        "_index": "zpark",
        "_type": "user",
        "_id": "2",
        "_score": 0.19284013,
        "_source": {
          "name": "ls",
          "realname": "李四",
          "age": 20,
          "birthday": "2017-10-20",
          "salary": 5000,
          "address": "北京市朝阳区三里屯街道21号"
        },
        "highlight": {
          "address": [
            "北京市朝阳<em>区</em>三里屯街道21号"
          ]
        }
      }
    ]
  }
}
```

#### 查询 name 是 zs 关键字的用户

> 基于Term词元查询

```json
GET /zpark/user/_search
{
  "query": {
    "term": {
      "realname": {
        "value": "王"
      }
    }
  }
}
```

#### Term和match区别

match会把搜索关键词分词，再在索引里比对，比如搜索词为王五，会分成“王”、“五”两个关键词，再比对索引；

term不会自动分词，会直接比对索引。

#### 范围查询

```json
#范围查询 查询(20,30]
GET /zpark/user/_search
{
  "query": {
    "range": {
      "age": {
        "gt": 20,
        "lte": 30
      }
    }
  }
}
```

#### 前缀查询

```json
#前缀查询
GET /zpark/user/_search
{
  "query": {
    "prefix": {
      "realname": {
        "value": "李"
      }
    }
  }
}
```

#### 通配符查询

```json
#通配符查询
#*匹配0-n个字符，？匹配一个字符
GET /zpark/user/_search
{
  "query": {
    "wildcard": {
      "name": {
        "value": "*s"
      }
    }
  }
}

```

#### 基于ids的查询

```json
#查询id为1,2,3的用户
GET /zpark/user/_search
{
  "query": {
    "ids": {
      "values": [1,2,3]
    }
  }
}
```

#### 基于Fuzzy的模糊查询

```json
#模糊查询
#查询名字中带有王的用户
GET /zpark/user/_search
{
  "query": {
    "fuzzy": {
      "realname": {
        "value": "王"
      }
    }
  }
}
```

#### 基于bool的条件查询

> 基于Boolean的查询（多条件查询）
> must ：查询结果必须符合该查询条件（列表）。
> should ：类似于or的查询条件。
> must_not ：查询结果必须不符合查询条件（列表）。

```json
#查询 age 在15-30岁之间并且 name 必须通配z*,name不能以s结尾
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "range": {
            "age": {
              "gte": 15,
              "lte": 30
            }
          }
        },
        {
          "wildcard": {
            "name": {
              "value": "z*"
            }
          }
        }
      ],
      "must_not": [
        {
          "regexp": {
            "name": ".*s"
          }
        }
      ]
    }
  }
}
```

### 过滤器（Filter）

​	准确来说，ES中的查询操作分为2种：查询（query）和过滤（filter）。查询即是之前提到的query查询，它（查询）默认会计算每个返回文档的得分，然后根据得分排序。而过滤（filter）只会筛选出符合的文档，并不计算得分，且它可以缓存文档。所以，单从性能考虑，过滤比查询更快。

​	换句话说，过滤适合在大范围筛选数据，而查询则适合精确匹配数据。一般应用时，应先使用过滤操作过滤数据，然后使用查询匹配数据。

#### 过滤器使用

```jspn
#过滤年龄大于等于25的用户
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match_all": {}
        }
      ],
      "filter": {
        "range": {
          "age": {
            "gte": 25
          }
        }
      }
    }
  }
}
```

> 注意： 过滤查询运行时先执行过滤语句，后执行普通查询

#### 过滤器类型

##### 1.term、terms Filter

term、terms的含义与查询时一致。term用于精确匹配、terms用于多词条匹配

```json
#查询姓名为zs的
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {"match_all": {}}
      ],
      "filter": {
        "term": {
          "name": "zs"
        }
      }
    }
  }
}
#查询姓名为zs、ls的
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {"match_all": {}}
      ],
      "filter": {
        "terms": {
          "name":[
            "zs",
            "ls"
          ]
        }
      }
    }
  }
}
```

##### 2.ranage Filter

```json
#过滤年龄为10-20的
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {"match_all": {}}
      ],
      "filter": {
        "range": {
          "age": {
            "gte": 10,
            "lte": 20
          }
        }
      }
    }
  }
}
```

##### 3.exists filter

```json
#过滤指定字段没有值的文档
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {"match_all": {}}
      ],
      "filter": {
        "exists": {
          "field": "name"
        }
      }
    }
  }
}
```

##### 4.ids filter

```json
#过滤若干id
GET /zpark/user/_search
{
  "query": {
    "bool": {
      "must": [
        {"match_all": {}}
      ],
      "filter": {
        "ids": {
          "values": [
            "1",
            "2"
          ]
        }
      }
    }
  }
}
```

##### 5.其它使用方式可查阅官网

> Note：
> Query和Filter更详细的对比可参考：https://blog.csdn.net/laoyang360/article/details/80468757

### 聚合（Aggregations）

https://www.elastic.co/guide/en/elasticsearch/reference/6.x/search-aggregations.html

​	聚合提供了功能可以分组并统计你的数据。理解聚合最简单的方式就是可以把它粗略的看做SQL的GROUP BY操作和SQL的聚合函数。

ES中常用的聚合：

- **metric（度量）聚合**：度量类型聚合主要针对的number类型的数据，需要ES做比较多的计算工作
- **bucketing（桶）聚合**：划分不同的“桶”，将数据分配到不同的“桶”里。非常类似sql中的group语句的含义

ES中的聚合API如下：

```json
"aggregations" : { 				// 表示聚合操作，可以使用aggs替代
	"<aggregation_name>" : { 	// 聚合名，可以是任意的字符串。用做响应的key，便于快速取得正确的响应数据。
		"<aggregation_type>" : { 							// 聚合类别，就是各种类型的聚合，如min等
			<aggregation_body> 								// 聚合体，不同的聚合有不同的body
		}
		[,"aggregations" : { [<sub_aggregation>]+ } ]? 		// 嵌套的子聚合，可以有0或多个
	}
	[,"<aggregation_name_2>" : { ... } ]* 					// 另外的聚合，可以有0或多个
}
```

#### 度量（metric）聚合

##### 1.Avg Aggregations

平均值查询，作用于number类型字段上

```json
#查询用户的平均年龄
POST /zpark/user/_search
{
  "aggs": {
    "age_avg": {
      "avg": {
        "field": "age"
      }
    }
  }
}
```

先过滤出来一些用户，再求这些用户平均年龄

```json
POST /zpark/user/_search
{
  "query": {
    "ids": {
      "values": [1,2,3]
    }
  },
  "aggs": {
    "avg_age": {
      "avg": {
        "field": "age"
      }
    }
  }
}
```

##### 2.Max Aggregations

最大值查询

```json
#查询员工的最高年龄
POST /zpark/user/_search
{
  "aggs": {
    "max_age": {
      "max": {
        "field": "age"
      }
    }
  }
}
```

##### 3.Min Aggregations

最小值查询

```json
#查询员工的最低年龄
POST /zpark/user/_search
{
  "aggs": {
    "min_age": {
      "min": {
        "field": "age"
      }
    }
  }
}
```

##### 4.Sum Aggregations

总和查询

```json
#查询员工的年龄和
POST /zpark/user/_search
{
  "aggs": {
    "sum_age": {
      "sum": {
        "field": "age"
      }
    }
  }
}
```

##### 5.Stats Aggregations

统计查询

```json
#一次性查出age字段常用的度量聚合
POST /zpark/user/_search
{
  "aggs": {
    "stats_age": {
      "stats": {
        "field": "age"
      }
    }
  }
}
```

#### 桶（bucketing）聚合

##### 1.Range Aggregations

自定义区间范围的聚合，我们可以自己手动地划分区间，ES会根据划分出来的区间将数据分配不同的区间上去。

```json
#统计10-20,20-30,30-40的人数
#[from,to)
POST /zpark/user/_search
{
  "aggs": {
    "range_age": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "from": 10,
            "to": 20
          },{
            "from": 20,
            "to": 30
          },
          {
            "from": 30,
            "to": 40
          }
        ]
      }
    }
  }
}
```

##### 2.Terms Aggregations

自定义分组依据Term，对分组后的数据进行统计

```json
#根据年龄分组，统计相同年龄的用户
#size表示要前2个数据
POST /zpark/user/_search
{
  "aggs": {
    "terms_age": {
      "terms": {
        "field": "age",
        "size": 2  
      }
    }
  }
}
```

##### 3.Date Range Aggregations

​	时间区间聚合专门针对date类型的字段，它与Range Aggregation的主要区别是其可以使用时间运算表达式。

- now+10y：表示从现在开始的第10年。
- now+10M：表示从现在开始的第10个月。
- 1990-01-10||+20y：表示从1990-01-01开始后的第20年，即2010-01-01。
- now/y：表示在年位上做舍入运算。

```json
#统计生日在2014,2015,2016的用户数
#[from,to)
POST /zpark/user/_search
{
  "aggs": {
    "date_range_age": {
      "date_range": {
        "field": "birthday",
        "format": "yyyy-MM-dd", 
        "ranges": [
          {
            "from": "now/y-5y",
            "to": "now/y-4y"
          },
          {
            "from": "now/y-4y",
            "to": "now/y-3y"
          },
          {
            "from": "now/y-3y",
            "to": "now/y-2y"
          }
        ]
      }
    }
  }
}
```

##### 4.Histogram Aggregations

​	直方图聚合，它将某个number类型字段等分成n份，统计落在每一个区间内的记录数。它与前面介绍的Range聚合非常像，只不过Range可以任意划分区间，而Histogram做等间距划分。既然是等间距划分，那么参数里面必然有距离参数，就是interval参数。

```json
#根据年龄间隔（5岁）统计
POST /zpark/user/_search
{
  "aggs": {
    "histogram_age_5": {
      "histogram": {
        "field": "age",
        "interval": 5
      }
    }
  }
}
```

##### 5.Date Histogram Aggregations

​	日期直方图聚合，专门对时间类型的字段做直方图聚合。这种需求是比较常用见得的，我们在统计时，通常就会按照固定的时间断（1个月或1年等）来做统计。

```json
#按年统计用户
POST /zpark/user/_search
{
  "aggs": {
    "date_histogram_bir": {
      "date_histogram": {
        "field": "birthday",
        "interval": "year",
        "format": "yyyy-MM-dd"
      }
    }
  }
}
```

#### 嵌套使用

​	聚合操作是可以嵌套使用的。通过嵌套，可以使得metric类型的聚合操作作用在每一bucket上。我们可以使用ES的嵌套聚合操作来完成稍微复杂一点的统计功能。

```json
#统计每年中用户的最高工资
POST /zpark/user/_search
{
  "aggs": {
    "user_year": {
      "date_histogram": {
        "field": "birthday",
        "interval": "year",
        "format": "yyyy-MM-dd"
      },
      "aggs": {
        "max_salary": {
          "max": {
            "field": "salary"
          }
        }
      }
    }
  }
}
```

