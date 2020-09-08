# Linux学习笔记

## 1.CentOS 7学习

#### 安装CentOS7.7

​	国内下载源：<https://mirrors.aliyun.com/centos/7.7.1908/isos/x86_64/>（阿里云镜像站）

##### CentOS7的各种安装包区别：

CentOS 7提供了三种ISO镜像文件的下载：
①DVD ISO 标准安装版，一般下载这个就可以了（推荐）
②Everything ISO 对完整版安装盘的软件进行补充，集成所有软件。（包含centos7的一套完整的软件包，可以用来安装系统或者填充本地镜像）
③Minimal ISO 精简版，自带的软件最少

CentOS-7.0-x86_64-DVD-1503-01.iso 标准安装版，一般下载这个就可以了（推荐）
CentOS-7.0-x86_64-NetInstall-1503-01.iso 网络安装镜像（从网络安装或者救援系统）
CentOS-7.0-x86_64-Everything-1503-01.iso 对完整版安装盘的软件进行补充，集成所有软件。（包含centos7的一套完整的软件包，可以用来安装系统或者填充本地镜像）
CentOS-7.0-x86_64-GnomeLive-1503-01.iso GNOME桌面版
CentOS-7.0-x86_64-KdeLive-1503-01.iso KDE桌面版
CentOS-7.0-x86_64-livecd-1503-01.iso 光盘上运行的系统，类拟于winpe
CentOS-7.0-x86_64-minimal-1503-01.iso 精简版，自带的软件最少

##### CentOS7的常用命令

```shell
#关机
shutdown -h now
#10分钟后关机
shutdown -h 10
#重启
shutdown -r now
#10分钟后重启
shutdown -r 10
#8点半重启
shutdown -r 08:30
#如果是通过shutdown命令设置重启的话，可以取消重启
shutdown -c

#查询ip信息
ip addr
#设置网络信息
vi /etc/sysconfig/network-scripts/ifcfg-ens33
#从vi命令进入文本后为命令模式，
#点“i”进入编辑模式，更改ONBOOT为yes，即开机自启动
#按ESC退出编辑，进入命令模式，
#点“:”进入底部模式
#“q!”强制退出不保存，“wq”保存退出
#重启network网络服务
service network restart



#检查java版本
java -version
#查找是否有已安装JDK
rpm -qa|grep java -i
#删除上述命令找到的jdk
rpm -e --nodeps 需要删除的软件

#安装jdk
#解压缩jdk安装包，配置环境变量
vi /etc/profile
#添加配置
export JAVA_HOME=/usr/java/jdk1.8.0_191
export CLASSPATH=.:%JAVA_HOME%/lib/dt.jar:%JAVA_HOME%/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
#重启配置
source /etc/profile
```

yum安装jdk

```shell
#查看JDK软件包列表
yum search java | grep -i --color jdk
#选择版本安装
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
#或者如下命令，安装jdk1.8.0的所有文件
yum install -y java-1.8.0-openjdk*
#查看JDK是否安装成功
java -version
#配置环境变量
#JDK默认安装路径/usr/lib/jvm
#在/etc/profile文件添加如下命令

set java environment  

JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.181-3.b13.el7_5.x86_64
PATH=$PATH:$JAVA_HOME/bin  
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar  
export JAVA_HOME  CLASSPATH  PATH 
#保存关闭profile文件，执行如下命令生效
source  /etc/profile
#使用如下命令，查看JDK变量
echo $JAVA_HOME
echo $PATH
echo $CLASSPATH
```

centOS7安装mariaDB

```shell
MySQL 已经不再包含在 CentOS 7 的源中，而改用了 MariaDB;

1.使用rpm -qa | grep mariadb搜索 MariaDB 现有的包：

如果存在，使用rpm -e --nodeps mariadb-*全部删除：

[root@localhost ~]# rpm -qa | grep mariadb
mariadb-server-5.5.52-1.el7.x86_64
mariadb-libs-5.5.52-1.el7.x86_64
[root@localhost ~]# rpm -e mysql-*
错误：未安装软件包 mysql-* 
 

2.使用rpm -qa | grep mariadb搜索 MariaDB 现有的包：

如果存在，使用yum remove mysql mysql-server mysql-libs compat-mysql51全部删除；

复制代码
[root@localhost ~]# yum remove mysql mysql-server mysql-libs compat-mysql51
已加载插件：fastestmirror, langpacks
参数 mysql 没有匹配
参数 mysql-server 没有匹配
参数 compat-mysql51 没有匹配
正在解决依赖关系
--> 正在检查事务
---> 软件包 mariadb-libs.x86_64.1.5.5.52-1.el7 将被 删除
--> 正在处理依赖关系 libmysqlclient.so.18()(64bit)，它被软件包 perl-DBD-MySQL-4.023-5.el7.x86_64 需要
--> 正在处理依赖关系 libmysqlclient.so.18()(64bit)，它被软件包 2:postfix-2.10.1-6.el7.x86_64 需要
--> 正在处理依赖关系 libmysqlclient.so.18()(64bit)，它被软件包 1:qt-mysql-4.8.5-13.el7.x86_64 需要..........
复制代码
复制代码
删除:
  mariadb-libs.x86_64 1:5.5.52-1.el7                                            

作为依赖被删除:
  akonadi-mysql.x86_64 0:1.9.2-4.el7     mariadb-server.x86_64 1:5.5.52-1.el7   
  perl-DBD-MySQL.x86_64 0:4.023-5.el7    postfix.x86_64 2:2.10.1-6.el7          
  qt-mysql.x86_64 1:4.8.5-13.el7        

完毕！
[root@localhost ~]# rpm -qa|grep mariadb
[root@localhost ~]#
复制代码
3.开始新的安装, 创建MariaDB.repo文件

vi /etc/yum.repos.d/MariaDB.repo
插入以下内容：
#使用中科大的速度更快些，安装如果报错，可能因为版本问题，把下面的版本或者安装版本改正即可
[mariadb]
name = MariaDB
baseurl = http://mirrors.ustc.edu.cn/mariadb/yum/10.3/centos7-amd64/
gpgkey=http://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
系统及版本选择：https://downloads.mariadb.org/mariadb/repositories/#mirror=tuna

4.运行安装命令安装MariaDB

复制代码
[root@localhost ~]# yum -y install MariaDB-server MariaDB-client


systemctl start mariadb #启动服务
systemctl enable mariadb #设置开机启动
systemctl restart mariadb #重新启动
systemctl stop mariadb.service #停止MariaDB
5.登录到数据库

　　用mysql -uroot命令登录到MariaDB，此时root账户的密码为空。

6.进行MariaDB的相关简单配置,使用mysql_secure_installation命令进行配置。

mysql_secure_installation
 

 首先是设置密码，会提示先输入密码

Enter current password for root (enter for none):<–初次运行直接回车

设置密码

Set root password? [Y/n] <– 是否设置root用户密码，输入y并回车或直接回车
New password: <– 设置root用户的密码
Re-enter new password: <– 再输入一次你设置的密码

其他配置

Remove anonymous users? [Y/n] <– 是否删除匿名用户，回车

Disallow root login remotely? [Y/n] <–是否禁止root远程登录,回车,

Remove test database and access to it? [Y/n] <– 是否删除test数据库，回车

Reload privilege tables now? [Y/n] <– 是否重新加载权限表，回车

初始化MariaDB完成，接下来测试登录

mysql -uroot -ppassword
完成。

 7.配置MariaDB的字符集

　　查看/etc/my.cnf文件内容，其中包含一句!includedir /etc/my.cnf.d 说明在该配置文件中引入/etc/my.cnf.d 目录下的配置文件。

　　1）使用vi server.cnf命令编辑server.cnf文件，在[mysqld]标签下添加

init_connect='SET collation_connection = utf8_unicode_ci' 
init_connect='SET NAMES utf8' 
character-set-server=utf8 
collation-server=utf8_unicode_ci 
skip-character-set-client-handshake
 

　　如果/etc/my.cnf.d 目录下无server.cnf文件，则直接在/etc/my.cnf文件的[mysqld]标签下添加以上内容。

2）文件/etc/my.cnf.d/client.cnf

vi /etc/my.cnf.d/client.cnf
在[client]中添加

default-character-set=utf8
3）文件/etc/my.cnf.d/mysql-clients.cnf

vi /etc/my.cnf.d/mysql-clients.cnf
在[mysql]中添加

default-character-set=utf8
 全部配置完成，重启mariadb

systemctl restart mariadb
之后进入MariaDB查看字符集

mysql> show variables like "%character%";show variables like "%collation%";
显示为

 

复制代码
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client    | utf8                      |
| character_set_connection | utf8                      |
| character_set_database  | utf8                      |
| character_set_filesystem | binary                    |
| character_set_results    | utf8                      |
| character_set_server    | utf8                      |
| character_set_system    | utf8                      |
| character_sets_dir      | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)

+----------------------+-----------------+
| Variable_name        | Value          |
+----------------------+-----------------+
| collation_connection | utf8_unicode_ci |
| collation_database  | utf8_unicode_ci |
| collation_server    | utf8_unicode_ci |
+----------------------+-----------------+
3 rows in set (0.00 sec)
复制代码
字符集配置完成。

8. 添加用户，设置权限

创建用户命令

mysql>create user username@localhost identified by 'password';
直接创建用户并授权的命令

mysql>grant all on *.* to username@localhost indentified by 'password';
授予外网登陆权限 

mysql>grant all privileges on *.* to username@'%' identified by 'password';
授予权限并且可以授权

mysql>grant all privileges on *.* to username@'hostname' identified by 'password' with grant option;
复制代码
MariaDB [mysql]> select host,user,password from user;
+-----------------------+-------+------------------------+
| host                  | user  | password               |
+-----------------------+-------+------------------------+
| localhost             | root  | *E87F9354F7E889A65E... |
| localhost.localdomain | root  | *E87F9354F7E889A65E... |
| 127.0.0.1             | root  | *E87F9354F7E889A65E... |
| ::1                   | root  | *E87F9354F7E889A65E... |
| localhost             |       |                        |
| localhost.localdomain |       |                        |
+-----------------------+-------+------------------------+
7 rows in set (0.00 sec)
复制代码
 查询各Schema和Table占用的空间:

复制代码
MariaDB [information_schema]> use information_schema;
MariaDB [information_schema]> select table_schema,round(sum(DATA_LENGTH/1024/1024),2) as datasize  from tables group by table_schema;
+--------------------+----------+
| table_schema       | datasize |
+--------------------+----------+
| common             |     0.05 |
| information_schema |     0.09 |
| mysql              |     9.11 |
| nemo               |   103.23 |
| river              |     3.78 |
+--------------------+----------+
5 rows in set (2.026 sec)

MariaDB [information_schema]> select table_name,concat(round(sum(data_length/1024/1024),2),'MB') as datasize from tables where table_schema='nemo' group by table_name;
+---------------------------------+----------+
| table_name | datasize |
+---------------------------------+----------+
| actions 　　　　　　　　 　　　| 0.05MB |
| addresses 　　　　　　　　 　　| 0.02MB |
| addressfieldattributes 　　 | 0.02MB |
| addressprops 　　　　　　 　　| 0.02MB |
| composedtypes 　　　　　　   | 1.52MB |
| composedtypeslp 　　　　　　 | 1.52MB |
| comptypegrp2comptype 　　   | 0.05MB |
| config　　　　　　　　　　　　 | 0.02MB |
| itemcockpittemplrels 　　   | 0.02MB |
| itemsynctimestamps 　　     | 2.52MB |
| keyfeature 　　　　　　　　   | 0.02MB |
| keyfeaturelp 　　　　　　    | 0.02MB |
| keyvaluemap 　　　　　　 　　 | 2.52MB |
| keywords 　　　　　　　　　　  | 0.02MB |
| keywordsuggestionrule 　　  | 0.02MB |
+---------------------------------+----------+
15 rows in set (0.544 sec)

 

复制代码
 

简单的用户和权限配置基本就这样了。

其中只授予部分权限把 其中 all privileges或者all改为select,insert,update,delete,create,drop,index,alter,grant,references,reload,shutdown,process,file其中一部分。

Linux系统教程：如何检查MariaDB服务端版本  http://www.linuxidc.com/Linux/2015-08/122382.htm

MariaDB Proxy读写分离的实现 http://www.linuxidc.com/Linux/2014-05/101306.htm

Linux下编译安装配置MariaDB数据库的方法 http://www.linuxidc.com/Linux/2014-11/109049.htm

CentOS系统使用yum安装MariaDB数据库 http://www.linuxidc.com/Linux/2014-11/109048.htm

安装MariaDB与MySQL并存 http://www.linuxidc.com/Linux/2014-11/109047.htm

 

忘记root用户名和密码
首先用 killall -TERM mysqld  向mysqld server 发送kill命令关掉mysqld server(不是 kill -9),你必须是UNIX的root用户或者是你所运行的SERVER上的同等用户，才能执行这个操作

然后  /usr/bin/mysqld_safe  --skip-grant-tables --skip-networking & 

登录 : mysql -p或者使用mysql无密码登录 

>use mysql 
>update user set password=password("new_pass") where user="root"; 

>flush privileges;

exit;

修改完成之后重启数据库,即可用修改好 root 密码登录 
```

