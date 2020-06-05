### poi ###

#### Poi基本介绍 ####

Apache开源的一个技术  用于对Excel文件进行导入导出操作

Poi 能够对新版xlsx 以及 老版xls两种Excel格式进行操作 

如果不是必须请使用Poi 

#### java代码逻辑流程 ####

1. 创建一个文件对象（工作簿）
2. 创建工作表对象
3. 创建一个行对象
4. 创建一个单元格对象
5. 在单元格中写入数据
6. 保存到本地 IO流

#### demo ####

##### 导入依赖 #####

```xml
<dependency>
  <groupId>org.apache.poi</groupId>
  <artifactId>poi</artifactId>
  <version>3.11</version>
</dependency>
```

##### java代码 #####

```java
		//1. 创建一个文件对象（工作簿）
        HSSFWorkbook workbook = new HSSFWorkbook();
        //2. 创建工作表对象
        HSSFSheet sheet = workbook.createSheet("guru");
        //3. 创建一个行对象
        HSSFRow row = sheet.createRow(0);
        //4. 创建一个单元格对象
        HSSFCell cell = row.createCell(0);
        //创建样式对象
        HSSFCellStyle cellStyle = workbook.createCellStyle();
        HSSFFont font = workbook.createFont();
        font.setColor((short)5);
        font.setFontName("宋体");
        cellStyle.setFont(font);
        //把样式应用到单元格
        cell.setCellStyle(cellStyle);
        //5. 在单元格中写入数据
        cell.setCellValue("guru");
        //6. 保存到本地 IO流
        workbook.write(new FileOutputStream(new File("F:\\百知JAVA\\四.后期项目\\7 poi\\guru.xls")));
```

##### 模拟导出上师表 #####

```java
HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("guru");
        HSSFRow row = sheet.createRow(0);
        String[] titles = {"编号","名字","图片地址","法号","状态"};
        for (int i = 0; i < titles.length; i++) {
            HSSFCell cell = row.createCell(i);
            cell.setCellValue(titles[i]);
        }
        List<Guru> list = guruDao.selectList(null);
        for (int i = 0; i < list.size(); i++) {
            HSSFRow row1 = sheet.createRow(i+1);
            HSSFCell cell1 = row1.createCell(0);
            cell1.setCellValue(list.get(i).getGuruId());
            HSSFCell cell2 = row1.createCell(1);
            cell2.setCellValue(list.get(i).getGuruName());
            HSSFCell cell3 = row1.createCell(2);
            cell3.setCellValue(list.get(i).getGuruImage());
            HSSFCell cell4 = row1.createCell(3);
            cell4.setCellValue(list.get(i).getGuruNickname());
            HSSFCell cell5 = row1.createCell(4);
            cell5.setCellValue(list.get(i).getGuruStatus());
        }
        workbook.write(new FileOutputStream(new File("F:\\guru.xls")));
```

#### 通过反射优化poi ####

##### 回顾反射 #####

类对象 **=** Class对象

通过反射获取对象所有属性的值，通过get方法

```java
		//创建对象
        Guru guru = new Guru(1,"恒","image/1.jpg","当仓央波切",1);
        //通过类的对象获取类对象
        Class<? extends Guru> guruClass = guru.getClass();
        //获取类所有属性，包含私有
        Field[] declaredFields = guruClass.getDeclaredFields();
        /*//打印查看所有属性的名字
        for (int i = 0; i < declaredFields.length; i++) {
            System.out.println(declaredFields[i].getName());
        }*/
        //拼接属性的get方法
        for (int i = 0; i < declaredFields.length; i++) {
            String fieldName = declaredFields[i].getName();
            String getName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);
            /*//打印查看get方法名
            System.out.println(getName);*/
            //调用get方法，返回值即为get方法返回值
            Object invoke = guruClass.getDeclaredMethod(getName, null).invoke(guru, null);
            System.out.println(invoke);
        }
```

##### 优化poi获取属性值 #####

```java
		HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("guru");
        HSSFRow row = sheet.createRow(0);
        String[] titles = {"编号","名字","图片地址","法号","状态"};
        for (int i = 0; i < titles.length; i++) {
            HSSFCell cell = row.createCell(i);
            cell.setCellValue(titles[i]);
        }
        List<Guru> list = guruDao.selectList(null);
        for (int i = 0; i < list.size(); i++) {
            HSSFRow row1 = sheet.createRow(i+1);
            //创建对象
            Guru guru = list.get(i);
            //通过类的对象获取类对象
            Class<? extends Guru> guruClass = guru.getClass();
            //获取类所有属性，包含私有
            Field[] declaredFields = guruClass.getDeclaredFields();
            //拼接属性的get方法
            for (int j = 0; j < declaredFields.length; j++) {
                String fieldName = declaredFields[j].getName();
                String getName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);
                //调用get方法，返回值即为get方法返回值
                Object invoke = guruClass.getDeclaredMethod(getName, null).invoke(guru, null);
                HSSFCell cell = row1.createCell(j);
                if(invoke instanceof Date){
                    cell.setCellValue((Date) invoke);
                }else if(invoke instanceof Integer){
                    cell.setCellValue((Integer) invoke);
                }else {
                    cell.setCellValue((String) invoke);
                }
            }
        }
        workbook.write(new FileOutputStream(new File("F:\\guru.xls")));
```

##### 标题数据的优化 #####

优化方向：自动获取标题数据

解决方法：使用注解

1.自定义一个注解

```java
/**
 * @Target(ElementType.FIELD) 只能用在属性上
 * @Retention(RetentionPolicy.RUNTIME) 范围Runtime
 * String name() default "";  代表可以写入一个值
 */
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ExcelTitle {
    String name() default "";
}
```

2.给实体类属性添加注解

```java
	@ExcelTitle(name = "编号")
    private Integer guruId;

    @ExcelTitle(name = "名字")
    private String guruName;

    @ExcelTitle(name = "图片路径")
    private String guruImage;

    @ExcelTitle(name = "法号")
    private String guruNickname;

    @ExcelTitle(name = "状态")
    private Integer guruStatus;
```

3.优化poi拿到标题数据

```java
		HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("guru");
        HSSFRow row = sheet.createRow(0);
        Guru guru = new Guru();
        //1.拿到类对象
        Class<? extends Guru> guruClass = guru.getClass();
        //2.拿到属性对象数组
        Field[] declaredFields = guruClass.getDeclaredFields();
        //3.遍历数组拿到对应注解
        for (int i = 0; i < declaredFields.length; i++) {
            //4.拿到注解对象
            ExcelTitle annotation = declaredFields[i].getAnnotation(ExcelTitle.class);
            //5.拿到注解中的name值
            String name = annotation.name();
            //6.创建单元格并把name值填入单元格
            HSSFCell cell = row.createCell(i);
            cell.setCellValue(name);
        }
        workbook.write(new FileOutputStream(new File("F:\\guru.xls")));
```

##### 导出数据优化完整版 #####

```java
		List<Guru> list = guruDao.selectList(null);
        //创建一个文件对象（工作簿）
        HSSFWorkbook workbook = new HSSFWorkbook();
        //创建工作表对象
        HSSFSheet sheet = workbook.createSheet("guru");
        //创建第一个行对象获取标题
        HSSFRow row = sheet.createRow(0);
        //获取一个类对象
        Class<? extends Guru> guruClass = list.get(0).getClass();
        //拿到属性对象数组
        Field[] declaredFields = guruClass.getDeclaredFields();
        //遍历数组拿到对应注解
        for (int i = 0; i < declaredFields.length; i++) {
            //拿到注解对象
            ExcelTitle annotation = declaredFields[i].getAnnotation(ExcelTitle.class);
            //拿到注解中的name值
            String name = annotation.name();
            //创建单元格并把name值填入单元格
            HSSFCell cell = row.createCell(i);
            cell.setCellValue(name);
        }
        //遍历获取属性值
        for (int i = 0; i < list.size(); i++) {
            HSSFRow row1 = sheet.createRow(i+1);
            //创建对象
            Guru guru = list.get(i);
            //通过类的对象获取类对象
            Class<? extends Guru> guruClass1 = guru.getClass();
            //获取类所有属性，包含私有
            Field[] declaredFields1 = guruClass1.getDeclaredFields();
            //拼接属性的get方法
            for (int j = 0; j < declaredFields1.length; j++) {
                //获取属性名
                String fieldName = declaredFields1[j].getName();
                //拼接get方法
                String getName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);
                //调用get方法，返回值即为get方法返回值
                Object invoke = guruClass.getDeclaredMethod(getName, null).invoke(guru, null);
                //创建单元格并注入属性的值
                HSSFCell cell = row1.createCell(j);
                if(invoke instanceof Date){
                    cell.setCellValue((Date) invoke);
                }else if(invoke instanceof Integer){
                    cell.setCellValue((Integer) invoke);
                }else {
                    cell.setCellValue((String) invoke);
                }
            }
        }
        //写出文件
        workbook.write(new FileOutputStream(new File("F:\\guru.xls")));
```

##### 导入数据优化 #####

```java
//读取文件
FileInputStream inputStream = new FileInputStream(new File("F:\\guru.xls"));
//处理流中的数据
HSSFWorkbook workbook = new HSSFWorkbook(inputStream);
//从工作簿中取出工作表对象
HSSFSheet sheet = workbook.getSheet("guru");
//获取最后一行的下标
int lastRowNum = sheet.getLastRowNum();
//不取标题栏，从1开始遍历行对象
for (int i = 1; i <= lastRowNum; i++) {
    //从工作表中取出行对象
    HSSFRow row = sheet.getRow(i);
    //从行对象中取出单元格数据并封装成实体类对象
    Guru guru = new Guru(
            (int)row.getCell(0).getNumericCellValue(),
            row.getCell(1).getStringCellValue(),
            row.getCell(2).getStringCellValue(),
            row.getCell(3).getStringCellValue(),
            (int) row.getCell(4).getNumericCellValue()
    );
    //插入数据库
    System.out.println(guru);
}
```

#### 工具类封装 ####

```java
/**
     * 把数据通过poi技术导出为Excel表格
     * @param list 需要导出的数据
     * @param sheetName 导出Excel表格的工作表对象名字
     * @param outputStream 需要响应到的输出流
     * @param <T> 泛型T为导出数据需要的list集合中的元素类型
     * @throws NoSuchMethodException 该集合中的T类没有get方法
     * @throws IOException 写出到输出流异常
     * @throws InvocationTargetException
     * @throws IllegalAccessException
     */
    public static <T> void exportPoi(List<T> list,String sheetName, OutputStream outputStream) throws NoSuchMethodException, IOException, InvocationTargetException, IllegalAccessException {
        //创建一个文件对象（工作簿）
        HSSFWorkbook workbook = new HSSFWorkbook();
        //创建工作表对象
        HSSFSheet sheet = workbook.createSheet(sheetName);
        //创建第一个行对象获取标题
        HSSFRow row = sheet.createRow(0);
        //获取一个类对象
        Class<? extends T> tClass = (Class) list.get(0).getClass();
        //拿到属性对象数组
        Field[] declaredFields = tClass.getDeclaredFields();
        //遍历数组拿到对应注解
        for (int i = 0; i < declaredFields.length; i++) {
            //拿到注解对象
            ExcelTitle annotation = declaredFields[i].getAnnotation(ExcelTitle.class);
            //拿到注解中的name值
            String name = annotation.name();
            //创建单元格并把name值填入单元格
            HSSFCell cell = row.createCell(i);
            cell.setCellValue(name);
        }
        //遍历获取属性值
        for (int i = 0; i < list.size(); i++) {
            HSSFRow row1 = sheet.createRow(i+1);
            //创建对象
            T t = list.get(i);
            //获取类所有属性，包含私有
            Field[] declaredFields1 = tClass.getDeclaredFields();
            //拼接属性的get方法
            for (int j = 0; j < declaredFields1.length; j++) {
                //获取属性名
                String fieldName = declaredFields1[j].getName();
                //拼接get方法
                String getName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);
                //调用get方法，返回值即为get方法返回值
                Object invoke = tClass.getDeclaredMethod(getName, null).invoke(t, null);
                //创建单元格并注入属性的值
                HSSFCell cell = row1.createCell(j);
                if(invoke instanceof Date){
                    cell.setCellValue((Date) invoke);
                }else if(invoke instanceof Integer){
                    cell.setCellValue((Integer) invoke);
                }else {
                    cell.setCellValue((String) invoke);
                }
            }
        }
        //写出文件
        workbook.write(outputStream);
    }
```

#### 其它封装成熟的poi框架或者小工具 ####

##### easypoi #####

1.导入依赖（注释掉原先的poi）

```xml
<dependency>
    <groupId>cn.afterturn</groupId>
    <artifactId>easypoi-base</artifactId>
    <version>3.2.0</version>
</dependency>
<dependency>
    <groupId>cn.afterturn</groupId>
    <artifactId>easypoi-web</artifactId>
    <version>3.2.0</version>
</dependency>
<dependency>
    <groupId>cn.afterturn</groupId>
    <artifactId>easypoi-annotation</artifactId>
    <version>3.2.0</version>
</dependency>
```

2.给要导出的数据对应的实体类加注解

```java
	@Excel  加在实体类的属性上 对应Excel表格中的一列数据
    @ExcelCollection 加在实体类的集合类型属性上 一对多导出
    @ExcelEntity  加在实体类的属性上（该属性是一个自定义对象）
    @ExcelIgnore 添加该注解的属性不会被导出
    @ExcelTarget 加在类上 给类起别名


    @Excel name 列表 属性对应的标题栏名字  orderNum 可以不给  replace 值的替换 {正常_0,冻结_1}
    exportFormat 日期格式化
```

3.导出

```java
		List<Guru> list = guruDao.selectList(null);
        //1.定义导出的相关参数
        ExportParams exportParams = new ExportParams("上师信息","guru", ExcelType.HSSF);
		//2.创建WorkBook对象
        Workbook workbook = ExcelExportUtil.exportExcel(exportParams, Guru.class, list);
		//3.保存到本地
        workbook.write(new FileOutputStream(new File("easypoitest.xls")));
```

​        

4.导入

```java
		//1.定义导入参数
        ImportParams importParams = new ImportParams();
        importParams.setTitleRows(1);
        importParams.setHeadRows(1);
        //2.读取文件  使用工具类
        List<Guru> objects = ExcelImportUtil.importExcel(new File("easypoitest.xls"), Guru.class, importParams);
        guruDao.insertMany(objects);
```

5.图片的导出

实体类图片地址属性上加注解  （注意：手动拼接图片绝对路径）

```
@Excel(name = "图片", type = 2 ,width = 40 , height = 20,imageType = 1)
private String guruImage;
```

6.图片的导入

实体类上添加注解  保存图片的地址

```
@Excel(name = "图片", type = 2 ,width = 40 , height = 20,imageType = 1,savePath = "src/main/webapp/img")
//需注意，选择相对路径时，在展示图片时要进行字符串截取，从img..开始
private String guruImage;
```

7.一对多 集合数据的导出

```java
@ExcelCollection(name = "音频详情")
private List<Audio> children;
```

注意：被导出对象也必须加上对应的注解  Audio对象必须加注解