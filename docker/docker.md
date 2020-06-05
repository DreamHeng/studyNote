# docker

​	虚拟化容器技术。Docker基于镜像，可以秒级启动各种容器，每一个容器都是一个完整的运行环境，容器之间相互隔离。

### 1.Linux安装Docker

##### 1.1.卸载旧版本的docker

```shell
$ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

##### 1.2.设置存储库

```shell
#安装软件包
$ sudo yum install -y yum-utils

#设置稳定的存储库
$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

##### 1.3.安装DOCKER引擎

```shell
#安装最新版的
$ sudo yum install docker-ce docker-ce-cli containerd.io
```

##### 1.4.配置阿里云镜像加速

```shell
$ sudo mkdir -p /etc/docker
$ sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://xp9xhwu5.mirror.aliyuncs.com"]
}
EOF
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

##### 1.5.Docker基本命令

```shell
#启动docker
$ sudo systemctl start docker

#设置开机自启动docker
$ sudo systemctl enable docker

#查看本地镜像
$ sudo docker images

#查看当前运行容器
$ sudo docker ps

#进入docker中的mysql容器命令界面中
$ docker exec -it mysql5.7 /bin/bash
#退出命令界面
$ exit;

#重启容器
$ docker restart mysql5.7

#删除容器
$ docker rm -f mysql5.7

```

##### 1.6.docker安装mysql5.7

```shell
#下载mysql5.7镜像
$ docker pull mysql:5.7

#创建实例并启动
#参数说明：
#-p端口映射 主机端口：容器端口
#-v文件夹挂载 主机文件夹：容器文件夹
#-e 环境变量配置
#--name 指令容器名称
#-d后台运行
$ docker run -p 3306:3306 --name mysql5.7 \
-v /mydata/mysql/log:/var/log/mysql \
-v /mydata/mysql/data:/var/lib/mysql \
-v /mydata/mysql/conf:/etc/mysql \
-e MYSQL_ROOT_PASSWORD=root \
-d mysql:5.7

#在外部挂载的mysql配置文件夹/mydata/mysql/conf中添加配置文件，并重启mysql5.7
$ vi /mydata/mysql/conf/my.cnf

[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
[mysqld]
init_connect='SET collation_connection = utf8_unicode_ci'
init_connect='SET NAMES utf8'
character-set-server=utf8
collation-server=utf8_unicode_ci
skip-character-set-client-handshake
#跳过域名解析
skip-name-resolve


```

##### 1.7.docker安装redis

```shell
#安装最新版redis
$ docker pull redis

#创建redis配置文件文件夹
$ mkdir -p /mydata/redis/conf
$ touch /mydata/redis/conf/redis.conf

#创建实例并启动redis，redis-server /etc/redis/redis.conf表示以这个配置文件启动redis
$ docker run -p 6379:6379 --name redis \
-v /mydata/redis/data:/data \
-v /mydata/redis/conf/redis.conf:/etc/redis/redis.conf \
-d redis redis-server /etc/redis/redis.conf

#使用redis镜像执行redis-cli命令连接
$ docker exec -it redis redis-cli

#设置redis为aof持久化保存，修改redis.conf配置文件，加上下面
appendonly yes


```

