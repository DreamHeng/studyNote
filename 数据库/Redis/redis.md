# 分布式缓存

​	即分布式系统里所使用的的缓存。

### 主要作用

- 提升读取速度性能
- 分布式计算领域
- 为数据库降低查询压力
- 跨服务器缓存
- 内存式缓存

# NoSQL

​	NoSQL，Not Only SQL，非关系型数据库。

### 优点

- 扩展方便
- 读写快速，高性能
- 成本低，因大多数NoSQL都是开源的

### 缺点

- 不提供对sql的支持
- 支持的特性不够丰富，如大多数NoSQL不支持事务
- 现有产品不如传统关系型数据库成熟

### 常见分类

键值对数据库：Redis，Memcache；

列存储数据库：HBase，Cassandra；

文档型数据库：MongoDB，CouchDB；

图形数据库：Neo4J，FlockDB。

# Redis

### Redis基本概念

- NoSQL数据库

- 常用作分布式缓存中间件

- key-value形式存储
- 提供海量数据存储访问
- 数据存储在内存里，读取更快
- 非关系型，分布式，开源，水平扩展

### Redis和Memcache对比

这两种是分布式常用的缓存方案。

- Memcache是简单的key-value存储，Redis数据类型比较丰富
- Memcache无法容灾，Redis可以实现主从同步、故障转移
- Memcache无法持久化，Redis可以持久化，属于内存数据库
- Memcache内存使用率较高
- Memcache多核处理，多线程，Redis单线程单核处理

### Redis安装

#### 1.版本选择

​	在任何版本的选择上，生产环境优先使用稳定版本，不稳定版本可以自己尝鲜使用。

Redis是开源软件，可以在Redis中文网站直接下载，安装教程在里面也有详细说明。

http://www.redis.cn/download.html

#### 2.下载、解压、编译Redis

```shell
$ wget http://download.redis.io/releases/redis-6.0.6.tar.gz
$ tar xzf redis-6.0.6.tar.gz
$ cd redis-6.0.6
$ make && make install

#中间若安装出错需要重装，记得make clean
```

注意，centos7在安装redis6.0之前需升级gcc到5以上

```shell
#升级到 5.3及以上版本
yum -y install centos-release-scl
yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
scl enable devtoolset-9 bash
```

注意：scl命令启用只是临时的，退出xshell或者重启就会恢复到原来的gcc版本。
如果要长期生效的话，执行如下：

```
echo "source /opt/rh/devtoolset-9/enable" >>/etc/profile
```



#### 3.开启使用

进入到解压后的 `src` 目录，通过如下命令启动Redis:

```shell
$ ./redis-server
```

可以使用内置的客户端与Redis进行交互

```shell
$ src/redis-cli
redis> set foo bar
OK
redis> get foo
"bar"
```

#### 4.配置Redis

1. 在utils下，拷贝`redis_init_script`到`/etc/init.d`目录中，目的是为了开机自启动

```shell
cp redis_init_script /etc/init.d/
```

2. 创建`/usr/local/redis`，用于存放配置文件

```shell
mkdir /usr/local/redis
```

3. 拷贝redis配置文件

```shell
cp redis.conf /usr/local/redis/
```

4. 修改`redis.conf`核心配置文件

   ①修改`daemonize no` -> `daemonize yes` ，目的是为了让redis启动在Linux后台运行

   ②修改Redis的工作目录：

   ```
   dir /usr/local/redis/working
   ```

   ③修改bind，绑定ip改为`0.0.0.0`，代表可以让远程连接，不受ip限制

   ```shell
   bind 0.0.0.0
   ```

   ④设置密码

   ```shell
   requirepass heng
   ```

5. 修改`redis_init_script`文件中的redis核心配置文件如下（以下修改的配置文件皆是拷贝过去使用的）

   ```shell
   CONF="/usr/local/redis/${REDISPORT}.conf"
   ```

   并且修改redis核心配置文件名称为`6379.conf`

6. 为redis启动脚本添加执行权限，随后运行启动redis

   ```shell
   chmod 777 redis_init_script
   ./redis_init_script start
   ```

7. 检查redis进程

   ```shell
   ps -ef | grep redis
   ```

   到此redis安装成功

8. 设置redis开机自启动，修改`redis_init_script`，添加以下内容

   ```shell
   #chkconfig: 22345 10 90
   #description: Start and Stop redis
   ```

   随后执行

   ```shell
   chkconfig redis_init_script on
   ```

   重启redis，再查看进程


9. 在`redis_init_script`中添加停止的密码

10. 查看redis是否存活

    ```
    redis-cli -a hengheng521 ping
    ```

    

### Redis基本使用

#### 1.Redis的数据类型

​	Redis有五种数据类型，分别为string（字符串）、hash（哈希）、list（列表）、set（集合）和zset（sorted set，有序集合）。五种数据类型都是指键值对里值的数据类型。

##### 1.1.string（字符串）

​	string是Redis中最基本的数据类型，与Memcached是一模一样的类型，都是一个key对应一个value。

​	string是二进制安全的，就是redis的string可以包含任何数据，比如jpg图片以及序列化后的对象。

​	string的一个键最大可以存储512MB的数据。

##### 1.2.hash（哈希）

​	Redis里hash是一个键值对集合，是一个string类型的field和value的映射表，特别适合存储对象。（不能嵌套对象，即属性值为string）。一个键最多可以存储2<sup>32</sup>-1个键值对，大概为40亿。

##### 1.3.list（列表）

​	Redis中list是简单的字符串列表，按照插入顺序排序，可以添加一个元素到列表的头部（左边）或尾部（右边）。一个列表最多存储2<sup>32</sup>-1个元素。

##### 1.4.set（集合）

​	Redis里的set是string类型的无序集合。集合是通过哈希表实现的，所以添加、查找、删除的复杂度都为O(1)。集合中最大元素为2<sup>32</sup>-1。

​	set类型数据，存入已有的元素时，会被忽略，返回0。

##### 1.5.zset（sorted set：有序集合）

​	Redis里的zset和set一样也是string类型元素的集合，都不允许重复元素。

​	和set不同的是，zset每存入一个元素都会关联一个double类型的分数，Redis正是通过分数来为集合里面的成员按照从小到大的顺序排序。zset的成员是唯一的，但是分数是可以重复的。

​	zset也是通过哈希表实现的，单个键可存储2<sup>32</sup>-1个元素。

#### 2.Redis的基本语法

​	Redis默认由16个数据库，在配置文件中可以配置，`databases = 16`，数据库是以索引标识的，0到15，默认使用0，可使用`select`命令切换数据库。

```shell
#切换到1号数据库
select 1
```

##### 2.1.Redis键（key）

​	Redis的数据存储都是以键值对的形式存储，所以这里先列出键的操作，也可以理解为五种数据类型共同操作键的语法。

```shell
#用于返回所有的Redis命令的详细信息，以数组形式展示,返回嵌套的Redis命令的详细信息列表。列表顺序是随机的
COMMAND

#该命令用于在 key 存在时删除 key；返回删除成功数目，
DEL key1 [key2..] 

#序列化给定 key ，并返回被序列化的值
DUMP key

#检查给定 key 是否存在；返回存在的key的数目
EXISTS key1 [key2..]

#为给定 key 设置过期时间
EXPIRE key seconds

#EXPIREAT 的作用和 EXPIRE 类似，都用于为 key 设置过期时间。 不同在于 EXPIREAT 命令接受的时间参数是 UNIX 时间戳(unix timestamp)
EXPIREAT key timestamp

#设置 key 的过期时间以毫秒计
PEXPIRE key milliseconds

#设置 key 过期时间的时间戳(unix timestamp) 以毫秒计
PEXPIREAT key milliseconds-timestamp

#查找所有符合给定模式( pattern，正则表达式)的 key；返回符合给定模式的key列表（array）
KEYS pattern

#将当前数据库的 key 移动到给定的数据库 db 当中；返回移除成功数
MOVE key db

#移除 key 的过期时间，key 将持久保持；返回修改成功数
PERSIST key

#以毫秒为单位返回 key 的剩余的过期时间；返回-1代表没有设置过期时间，-2代表设置过过期时间并且已过期，其它正数代表剩余的过期时间
PTTL key

#以秒为单位，返回给定 key 的剩余生存时间(TTL, time to live)；返回同PTTL
TTL key

#从当前数据库中随机返回一个 key 
RANDOMKEY

#修改 key 的名称；成功返回OK，失败报错；修改成功后，查询旧key的剩余时间会返回-2；若新key存在，则覆盖掉新key
RENAME key newkey

#仅当 newkey 不存在时，将 key 改名为 newkey；成功返回1，失败返回0
RENAMENX key newkey

#返回 key 所储存的值的类型，不存在则返回none
TYPE key
```

##### 2.2.Redis字符串（string）

```shell
#设置指定 key 的值
SET key value

#获取指定 key 的值
GET key

#返回 key 中字符串值的子字符；如“limeng”，“0 3”返回”lime“，”0 -1“返回”limeng“
GETRANGE key start end

#将给定 key 的值设为 value ，并返回 key 的旧值(old value)；若不存在返回nio
GETSET key value

#获取所有(一个或多个)给定 key 的值
MGET key1 [key2..]

#对 key 所储存的字符串值，设置或清除指定偏移量上的位(bit)
SETBIT key offset value
#对 key 所储存的字符串值，获取指定偏移量上的位(bit)
GETBIT key offset
#将值 value 关联到 key ，并将 key 的过期时间设为 seconds (以秒为单位)
SETEX key seconds value
#只有在 key 不存在时设置 key 的值
SETNX key value
#用 value 参数覆写给定 key 所储存的字符串值，从偏移量 offset 开始
SETRANGE key offset value
#返回 key 所储存的字符串值的长度
STRLEN key
#同时设置一个或多个 key-value 对
MSET key value [key value ...]
#同时设置一个或多个 key-value 对，当且仅当所有给定 key 都不存在
MSETNX key value [key value ...]
#这个命令和 SETEX 命令相似，但它以毫秒为单位设置 key 的生存时间，而不是像 SETEX 命令那样，以秒为单位
PSETEX key milliseconds value
#将 key 中储存的数字值增一
INCR key
#将 key 所储存的值加上给定的增量值（increment）
INCRBY key increment
#将 key 所储存的值加上给定的浮点增量值（increment）
INCRBYFLOAT key increment
#将 key 中储存的数字值减一
DECR key
#key 所储存的值减去给定的减量值（decrement）
DECRBY key decrement
#如果 key 已经存在并且是一个字符串， APPEND 命令将指定的 value 追加到该 key 原来值（value）的末尾
APPEND key value
```

