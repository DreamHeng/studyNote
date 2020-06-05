##### 简介 #####

echarts 百度开源的技术  用于实现数据统计信息的图形展示   图形展示的优点：直观简洁

#### 开发步骤 ####

##### 1.引入js文件 #####

```jsp
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min1.3.5.js"></script>
//基础包
<script type="text/javascript" src="${pageContext.request.contextPath}/js/echarts.js"></script>
//中国地图用的包
<script type="text/javascript" src="${pageContext.request.contextPath}/js/china.js"></script>
```

##### 2.写入一个div  div的大小就是图表显示的大小 #####

```jsp
<!-- 用户男女比例对比统计 -->
<div id="test" style="width: 600px;height:400px;"></div>
<!-- 统计过去三周的用户注册量变化 -->
<div id="test1" style="width: 600px;height:400px;"></div>
<%--根据各省用户人数展示--%>
<div id="china" style="width: 600px;height:400px;"></div>
```

##### 3.使用js代码初始化图表 #####

​	**3.1 柱形图展示**

​		界面设置

```javascript
		// 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById('test'));

        // 指定图表的配置项和数据
        var option = {
            // 图形的标题
            title: {
                text: '持明法洲用户性别信息统计'
            },
            // 工具栏
            tooltip: {},
            // 定义图例的相关信息  对象
            legend: {
                data:['用户']
            },
            // x轴显示的坐标值  属性名
            xAxis: {
                data: ["男","女"]
            },
            yAxis: {}

        };

        // 使用刚指定的配置项和数据显示图表。
        myChart.setOption(option);
```

​			处理数据，利用ajax请求数据，数据类型为Map类型

```javascript
		// 通过ajax请求后台数据 修改series中data数据  什么样的json
        $.ajax({
            url:"${pageContext.request.contextPath}/user/getUserBySex",
            type:"get",
            dataType:"json",
            success:function (data) {
                option = {
                    series: [{
                        // 用户图例的数据
                        name: '用户',
                        type: 'line',
                        //以下的男、女为map的key
                        data: [data.男,data.女]
                    }]
                }
                myChart.setOption(option);
            }
        })

```

​	**3.2 现状图展示**

​		界面展示设置

```javascript
		// 1.基于准备好的dom，初始化echarts实例
        var myChart1 = echarts.init(document.getElementById('test1'));

        // 2.指定图表的配置项和数据
        var option1 = {
            title: {
                text: '过去三月用户注册量变化'
            },
            tooltip: {},
            legend: {
                data:['注册量']
            },
            xAxis: {
                data: ["过去三月","过去两月","过去一月"]
            },
            yAxis: {}
        };
		// 3.使用刚指定的配置项和数据显示图表。
        myChart1.setOption(option1);
```

​		处理数据，利用ajax请求，数据类型为Integet数组

```javascript
		// 此处写ajax请求
        $.ajax({
            url:"${pageContext.request.contextPath}/user/getUserByTime",
            type:"get",
            dataType:"json",
            success:function (data) {
                option = {
                    series: [{
                        name: '注册量',
                        type: 'line',
                        data: [data[2], data[1], data[0]]
                    }]
                }
                myChart1.setOption(option);
            }
        })
```

​	3.3 地图数据展示

​		界面展示设置

```javascript
 // 基于准备好的dom，初始化echarts实例
        var myChina = echarts.init(document.getElementById('china'));

        var option3 = {
            title : {
                text: '用户地区分布',
                left: 'center'
            },
            tooltip : {
                trigger: 'item'
            },
            legend: {
                orient: 'vertical',
                left: 'left',
                data:['用户人数']
            },
            visualMap: {
                min: 0,
                max: 2500,
                left: 'left',
                top: 'bottom',
                text:['高','低'],           // 文本，默认为数值文本
                calculable : true
            },
            toolbox: {
                show: true,
                orient : 'vertical',
                left: 'right',
                top: 'center',
                feature : {
                    mark : {show: true},
                    dataView : {show: true, readOnly: false},
                    restore : {show: true},
                    saveAsImage : {show: true}
                }
            },
            series : [
                {
                    name: '用户人数',
                    type: 'map',
                    mapType: 'china',
                    roam: false,
                    label: {
                        normal: {
                            show: false
                        },
                        emphasis: {
                            show: true
                        }
                    }
                }
            ]
        };
        myChina.setOption(option3)
```

​		接收数据并处理，数据类型为List<Map>，每条Map中有两条数据，一条key为name，value为省份，不带省这个字，如‘河南’、‘内蒙古’；另一条key为value，value为省份用户统计值。**数据必须这样！！！**

```javascript
		// 使用ajax请求数据
        $.ajax({
            url:"${pageContext.request.contextPath}/user/getUserByCity",
            type:"get",
            dataType:"json",
            success:function (data) {
                myChina.setOption({
                    series: [{
                        name: '人数',
                            type: 'map',
                            mapType: 'china',
                            roam: false,
                            label: {
                            normal: {
                                show: false
                            },
                            emphasis: {
                                show: true
                            }
                        },
                        data:data
                    }]
                });
            }
        })
```

#### 额外知识点 ####

##### 一次查询多条语句 #####

```mysql
		select count(u.guru_id) from cmfz_user u where datediff(NOW(),u.create_date) BETWEEN 0 and 30
        union select count(u.guru_id) from cmfz_user u where datediff(NOW(),u.create_date) BETWEEN 31 and 60
        union select count(u.guru_id) from cmfz_user u where datediff(NOW(),u.create_date) BETWEEN 61 and 90
```

##### 日期间隔函数 #####

```mysql
-- 返回值即为从现在开始减去u.pdate的天数
datediff(NOW(),u.pdate)
```

