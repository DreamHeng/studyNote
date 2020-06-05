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

